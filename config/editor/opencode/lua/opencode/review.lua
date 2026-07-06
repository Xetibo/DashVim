local M = {}

M.active_reviews = {}
M.current_session = nil
M.review_ns = vim.api.nvim_create_namespace("opencode_review")

-- Define highlight group for review comment lines
vim.cmd("highlight default OpenCodeReviewComment guibg=#3d3522 guifg=NONE")

local ft_map = {
  lua  = "lua",
  py   = "python",
  ts   = "typescript",
  tsx  = "typescriptreact",
  jsx  = "javascriptreact",
  js   = "javascript",
  rs   = "rust",
  go   = "go",
  nix  = "nix",
  md   = "markdown",
  json = "json",
  yaml = "yaml",
  yml  = "yaml",
  css  = "css",
  html = "html",
  sh   = "sh",
  bash = "sh",
  zsh  = "sh",
}

local function git_lines(cmd)
  local ok, result = pcall(vim.fn.systemlist, cmd)
  if not ok then
    return {}
  end
  local lines = {}
  for _, line in ipairs(result) do
    if line ~= "" then
      table.insert(lines, line)
    end
  end
  return lines
end

--- Returns union of staged, unstaged, and untracked files.
--- Returns empty table if no changes found.
function M.get_changed_files()
  local seen = {}
  local files = {}

  local function add(lines)
    for _, f in ipairs(lines) do
      if not seen[f] then
        seen[f] = true
        table.insert(files, f)
      end
    end
  end

  add(git_lines("git diff --cached --name-only"))
  add(git_lines("git diff --name-only"))
  add(git_lines("git ls-files --others --excluded-standard"))

  return files
end

--- Create a scratch review buffer for the given filepath.
--- Reads file from disk, stores original lines, resolves filetype from extension.
--- Returns bufnr, or nil if file not found.
function M.create_review_buffer(filepath)
  if vim.fn.filereadable(filepath) == 0 then
    vim.notify("File not found: " .. filepath, vim.log.levels.WARN)
    return nil
  end

  local lines = vim.fn.readfile(filepath)
  local buf = vim.api.nvim_create_buf(true, false)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_name(buf, "[Review] " .. filepath)
  vim.b[buf].review_original = lines

  -- Resolve filetype from extension
  local ext = filepath:match("%.([^%.]+)$")
  local resolved_ft = ext and ft_map[ext] or "text"
  if not ext then
    resolved_ft = "text"
  elseif ft_map[ext] then
    resolved_ft = ft_map[ext]
  end
  vim.bo[buf].filetype = resolved_ft

  return buf
end

function M.refresh_highlight(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, M.review_ns, 0, -1)

  local original = vim.b[bufnr].review_original
  if not original then
    return
  end

  local current = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local max_lines = math.max(#original, #current)
  for i = 1, max_lines do
    local orig_line = original[i]
    local curr_line = current[i]
    if orig_line ~= curr_line then
      local ok, err = pcall(vim.api.nvim_buf_set_extmark, bufnr, M.review_ns, i - 1, 0, {
        hl_group = "OpenCodeReviewComment",
        hl_eol = true,
        priority = 200,
      })
      if not ok then
        break
      end
    end
  end
end

--- Collect comments from all active review buffers.
--- Returns array of { file, line, code_before[], code_after[], comment } tables.
function M.collect_comments()
  local results = {}
  if not M.current_session then
    return results
  end

  for _, bufnr in ipairs(M.current_session.bufnrs) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      local meta = M.active_reviews[bufnr]
      if meta then
        local original = vim.b[bufnr].review_original or {}
        local current = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

        local max_lines = math.max(#original, #current)
        for i = 1, max_lines do
          local orig_line = original[i]
          local curr_line = current[i]

          -- curr_line nil = line deleted (original had content, current doesn't) — skip
          -- orig_line nil = newly inserted line — treat as comment
          -- Both non-nil but differ = modified line — treat as comment
          if curr_line and curr_line ~= orig_line then
            table.insert(results, {
              file = meta.path,
              line = i,
              code_before = orig_line and { orig_line } or {},
              code_after = { curr_line },
              comment = curr_line,
            })
          end
        end
      end
    end
  end

  return results
end

--- Write review comments to .omo/review-<session-id>.json
--- Returns filepath or nil on failure
function M.write_review_file(comments)
  if not M.current_session then
    vim.notify("No active session to write", vim.log.levels.WARN)
    return nil
  end

  -- Build the review payload matching the JSON schema from the plan
  local payload = {
    review_id = M.current_session.id,
    timestamp = M.current_session.timestamp,
    files = {},
  }

  -- Group comments by file
  local file_map = {}
  for _, c in ipairs(comments) do
    if not file_map[c.file] then
      file_map[c.file] = { path = c.file, comments = {} }
    end
    table.insert(file_map[c.file].comments, {
      line = c.line,
      code_before = c.code_before,
      code_after = c.code_after,
      comment = c.comment,
    })
  end

  -- Convert file_map to array
  for _, v in pairs(file_map) do
    table.insert(payload.files, v)
  end

  -- Ensure .omo/ directory exists
  local omo_dir = vim.fn.getcwd() .. "/.omo"
  if vim.fn.isdirectory(omo_dir) == 0 then
    vim.fn.mkdir(omo_dir, "p")
  end

  -- Write JSON file
  local filepath = omo_dir .. "/" .. M.current_session.id .. ".json"
  local ok, json = pcall(vim.fn.json_encode, payload)
  if not ok then
    vim.notify("Failed to encode review JSON", vim.log.levels.ERROR)
    return nil
  end

  vim.fn.writefile({ json }, filepath)
  return filepath
end

--- Orchestration entry point for review completion.
--- Validates session, collects comments, stores them for downstream use.
function M.complete()
  if not M.current_session or #M.current_session.bufnrs == 0 then
    vim.notify("No active review session", vim.log.levels.WARN)
    return
  end

  local comments = M.collect_comments()

  if #comments == 0 then
    vim.notify("No review comments found. Insert text in review buffers first.", vim.log.levels.INFO)
    return
  end

  -- Write review JSON
  local filepath = M.write_review_file(comments)
  if not filepath then
    vim.notify("Failed to write review file", vim.log.levels.ERROR)
    return
  end

  vim.notify("Wrote " .. #comments .. " review comments to " .. filepath, vim.log.levels.INFO)

  -- Handoff: try to send to opencode terminal
  local opencode = require("opencode")
  if opencode.job_id then
    local ok_send, _ = pcall(vim.api.nvim_chan_send, opencode.job_id,
      "Review comments in " .. filepath .. ". Process each comment and update the code.\n")
    if ok_send then
      vim.notify("Sent " .. #comments .. " review comments to OpenCode agent", vim.log.levels.INFO)
    else
      vim.notify("OpenCode terminal not available. Review file: " .. filepath, vim.log.levels.INFO)
    end
  else
    vim.notify("OpenCode terminal not running. Review file: " .. filepath, vim.log.levels.INFO)
  end

  -- Clean up session state
  M.current_session = nil
  M._pending_comments = nil
  -- Note: buffers remain open so user can review what they wrote
end

function M.open()
  local files = M.get_changed_files()
  if #files == 0 then
    vim.notify("No changes to review", vim.log.levels.INFO)
    return
  end

  M.current_session = {
    id = "review-" .. os.date("%Y%m%d-%H%M%S"),
    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    bufnrs = {},
  }

  local first = true
  for _, filepath in ipairs(files) do
    local bufnr = M.create_review_buffer(filepath)

    if bufnr then
      local lines = vim.b[bufnr].review_original
      if lines then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      end

      M.active_reviews[bufnr] = { path = filepath, bufnr = bufnr }
      table.insert(M.current_session.bufnrs, bufnr)

      local augroup = "OpenCodeReview_" .. bufnr
      vim.api.nvim_create_augroup(augroup, { clear = true })
      vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
        group = augroup,
        buffer = bufnr,
        callback = function()
          M.refresh_highlight(bufnr)
        end,
      })
      vim.api.nvim_create_autocmd("BufDelete", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          M.active_reviews[bufnr] = nil
          pcall(vim.api.nvim_del_augroup_by_name, augroup)
        end,
      })
      M.refresh_highlight(bufnr)

      vim.api.nvim_open_win(bufnr, first, {
        split = "below",
        height = 20,
      })
      first = false
    end
  end

  vim.notify(
    "Review session started: " .. #M.current_session.bufnrs .. " files",
    vim.log.levels.INFO
  )
end

return M
