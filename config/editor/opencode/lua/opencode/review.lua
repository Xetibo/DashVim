--- Review module for OpenCode.
---
--- Flow:
---   1. :OpenCodeReview  — starts session, opens DiffviewOpen for visual diff
---   2. :OpenCodeReviewComment  — opens a floating popover below the cursor for inline comment entry
---   3. :OpenCodeReviewComplete — collects all comments, writes .omo/review-*.json, sends to agent
---
--- Comments are stored in memory. No working tree files are modified.

local M = {}

M.current_session = nil

--- Stored review comments: { [abs_path] = { { line = N, comment = "..." }, ... } }
M.comments = {}

--- Start a review session: open DiffviewOpen to show working tree changes.
function M.open()
  -- No early-exit check on git changes — DiffviewOpen handles empty diffs gracefully
  M.comments = {}

  M.current_session = {
    id = "review-" .. os.date("%Y%m%d-%H%M%S"),
    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
  }

  vim.g.in_review_session = true
  pcall(vim.cmd, "DiffviewOpen")
  vim.cmd("redrawstatus")

  vim.notify(
    "Review session started. Navigate to a changed line and run :OpenCodeReviewComment.",
    vim.log.levels.INFO
  )
end

--- Tracks the active comment popover so module-level callbacks can access it.
--- @type { buf: integer, win: integer, file: string, line: integer }|nil
M._comment_popover = nil

--- Add a comment on the current line in the current buffer.
--- Opens a floating popover below the cursor for inline text entry.
--- The file path is resolved from the buffer name. The comment is stored in
--- memory under M.comments and does NOT modify the working tree file.
function M.add_comment()
  if not M.current_session then
    vim.notify("No active review session. Start one with :OpenCodeReview.", vim.log.levels.WARN)
    return
  end

  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file associated with current buffer", vim.log.levels.WARN)
    return
  end

  local line = vim.fn.line(".")

  local buf = vim.api.nvim_create_buf(false, true)

  local width = math.min(60, vim.o.columns - 8)
  local height = 3

  -- Position below cursor; if near bottom of screen, place above instead
  local cursor_win_row = vim.fn.screenpos(vim.api.nvim_get_current_win(), line, 0)
  local row_from_cursor = 2
  local screen_rows = vim.o.lines - vim.o.cmdheight - 2
  if cursor_win_row and cursor_win_row.row + height + 2 > screen_rows then
    row_from_cursor = -(height + 1)
  end

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    width = width,
    height = height,
    row = row_from_cursor,
    col = 0,
    style = 'minimal',
    border = 'single',
    title = ' Review Comment ',
    title_pos = 'center',
  })

  vim.wo[win].winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder'

  M._comment_popover = { buf = buf, win = win, file = file, line = line }

  -- Confirm: F2 in insert or normal mode
  vim.keymap.set('i', '<F2>', function()
    vim.notify("[review] F2 confirm", vim.log.levels.INFO)
    M._confirm_popover()
  end, { buffer = buf })
  vim.keymap.set('n', '<F2>', function()
    vim.notify("[review] F2 confirm", vim.log.levels.INFO)
    M._confirm_popover()
  end, { buffer = buf })
  -- Cancel
  vim.keymap.set('i', '<Esc>', function()
    M._cancel_popover()
  end, { buffer = buf })
  vim.keymap.set('n', 'q', function()
    M._cancel_popover()
  end, { buffer = buf })

  vim.api.nvim_win_set_cursor(win, { 1, 0 })
  vim.cmd('startinsert')
end

--- Confirm handler for the active comment popover.
--- Called via <Cmd> mapping from the popover buffer.
function M._confirm_popover()
  local pop = M._comment_popover
  if not pop then return end
  M._comment_popover = nil

  local lines = vim.api.nvim_buf_get_lines(pop.buf, 0, -1, false)
  while #lines > 0 and lines[#lines] == "" do
    table.remove(lines)
  end
  local comment_text = table.concat(lines, "\n")

  if comment_text ~= "" then
    if not M.comments[pop.file] then
      M.comments[pop.file] = {}
    end
    table.insert(M.comments[pop.file], { line = pop.line, comment = comment_text })
    vim.notify(
      string.format("Review comment added at %s:%d", vim.fn.fnamemodify(pop.file, ":t"), pop.line),
      vim.log.levels.INFO
    )
  end

  vim.schedule(function()
    pcall(vim.api.nvim_win_close, pop.win, true)
    pcall(vim.api.nvim_buf_delete, pop.buf, { force = true })
  end)
end

--- Cancel handler for the active comment popover.
function M._cancel_popover()
  local pop = M._comment_popover
  if not pop then return end
  M._comment_popover = nil

  vim.schedule(function()
    pcall(vim.api.nvim_win_close, pop.win, true)
    pcall(vim.api.nvim_buf_delete, pop.buf, { force = true })
  end)
end

--- Collect stored comments into the review payload format.
--- @return table  array of { file, line, code_before, code_after, comment }
function M.collect_comments()
  local results = {}
  if not M.current_session then
    return results
  end

  local cwd = vim.fn.getcwd()

  for abs_path, file_comments in pairs(M.comments) do
    local rel_path = abs_path
    if abs_path:sub(1, #cwd) == cwd then
      rel_path = abs_path:sub(#cwd + 2)
    end

    for _, c in ipairs(file_comments) do
      table.insert(results, {
        file = rel_path,
        line = c.line,
        code_before = {},
        code_after = {},
        comment = c.comment,
      })
    end
  end

  return results
end

--- Write review comments to .omo/review-<session-id>.json
--- @param comments table  array of comment tables
--- @return string|nil  filepath on success, nil on failure
function M.write_review_file(comments)
  if not M.current_session then
    vim.notify("No active session to write", vim.log.levels.WARN)
    return nil
  end

  local payload = {
    review_id = M.current_session.id,
    timestamp = M.current_session.timestamp,
    files = {},
  }

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

  for _, v in pairs(file_map) do
    table.insert(payload.files, v)
  end

  local omo_dir = vim.fn.getcwd() .. "/.omo"
  if vim.fn.isdirectory(omo_dir) == 0 then
    vim.fn.mkdir(omo_dir, "p")
  end

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
--- Collects comments, writes review file, sends to agent, cleans up.
function M.complete()
  if not M.current_session then
    vim.notify("No active review session", vim.log.levels.WARN)
    return
  end

  local comments = M.collect_comments()

  if #comments == 0 then
    vim.notify("No review comments. Use :OpenCodeReviewComment to add comments before completing.", vim.log.levels.INFO)
    -- Clean up stale session
    M.current_session = nil
    M.comments = {}
    vim.g.in_review_session = false
    return
  end

  local filepath = M.write_review_file(comments)
  if not filepath then
    vim.notify("Failed to write review file", vim.log.levels.ERROR)
    return
  end

  vim.notify("Wrote " .. #comments .. " review comments to " .. filepath, vim.log.levels.INFO)

  local msg = string.format("Review file %s has %d comments. Read the file, process each comment, and update the code.",
    filepath, #comments)

  local opencode = require("opencode")
  opencode.run_prompt(msg)

  M.current_session = nil
  M.comments = {}
  vim.g.in_review_session = false
end

--- Complete review and hand off to avante.nvim instead of the opencode
--- terminal. Writes the same .omo/review-*.json, then opens the Avante
--- sidebar with a prompt referencing the file. Keeps the session alive on
--- failure so the user can retry with :OpenCodeReviewComplete.
function M.complete_avante()
  if not M.current_session then
    vim.notify("No active review session", vim.log.levels.WARN)
    return
  end

  local comments = M.collect_comments()

  if #comments == 0 then
    vim.notify("No review comments. Use :OpenCodeReviewComment to add comments before completing.", vim.log.levels.INFO)
    -- Clean up stale session
    M.current_session = nil
    M.comments = {}
    vim.g.in_review_session = false
    return
  end

  local filepath = M.write_review_file(comments)
  if not filepath then
    vim.notify("Failed to write review file", vim.log.levels.ERROR)
    return
  end

  -- Force-load avante (lazy-loaded on its commands only)
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    pcall(lazy.load, { plugins = { "avante.nvim" } })
  end

  local api_ok, api = pcall(require, "avante.api")
  if not api_ok then
    vim.notify("avante.nvim not available. Review file written to " .. filepath, vim.log.levels.ERROR)
    return
  end

  vim.notify("Wrote " .. #comments .. " review comments to " .. filepath, vim.log.levels.INFO)

  local msg = string.format(
    "Review file %s has %d comments. Read the file, process each comment, and update the code accordingly.",
    filepath,
    #comments
  )

  api.ask({ question = msg })

  M.current_session = nil
  M.comments = {}
  vim.g.in_review_session = false
end

return M
