local M = {}

M.bufnr = nil
M.winnr = nil
M.job_id = nil

local function create_opencode_buffer()
  if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then
    return M.bufnr
  end

  M.bufnr = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(M.bufnr, "opencode")
  vim.bo[M.bufnr].buftype = "nofile"

  return M.bufnr
end

local function open_opencode_window(buf)
  -- If already visible, focus it
  if M.winnr and vim.api.nvim_win_is_valid(M.winnr) then
    vim.api.nvim_set_current_win(M.winnr)
    return
  end

  -- Open in a vertical split (right side)
  vim.cmd("vsplit")
  M.winnr = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(M.winnr, buf)
end

local function start_terminal(buf)
  if M.job_id then
    return
  end

  vim.api.nvim_set_current_buf(buf)
  M.job_id = vim.fn.termopen("opencode", {
    on_exit = function()
      M.job_id = nil
      M.bufnr = nil
    end,
  })
end

function M.toggle()
  if M.winnr and vim.api.nvim_win_is_valid(M.winnr) then
    vim.api.nvim_win_close(M.winnr, true)
    M.winnr = nil
    return
  end

  local buf = create_opencode_buffer()
  open_opencode_window(buf)

  if not M.job_id then
    start_terminal(buf)
  end

  vim.cmd("startinsert")
end

function M.focus()
  if M.bufnr and vim.api.nvim_buf_is_valid(M.bufnr) then
    if not (M.winnr and vim.api.nvim_win_is_valid(M.winnr)) then
      open_opencode_window(M.bufnr)
    else
      vim.api.nvim_set_current_win(M.winnr)
    end
    vim.cmd("startinsert")
  else
    M.toggle()
  end
end

function M.diff_review()
  -- Open diffview to review changes made by opencode
  vim.cmd("DiffviewOpen")
end

function M.diff_accept()
  -- Accept all changes (close diffview, stage everything)
  vim.cmd("DiffviewClose")
  vim.cmd("!git add -A")
  vim.notify("OpenCode changes accepted and staged", vim.log.levels.INFO)
end

function M.diff_reject()
  -- Reject all changes (restore from git)
  vim.cmd("DiffviewClose")
  vim.cmd("!git checkout -- .")
  vim.notify("OpenCode changes rejected", vim.log.levels.WARN)
end

function M.setup(_)
  -- Create user commands
  vim.api.nvim_create_user_command("OpenCode", function() M.toggle() end, { desc = "Toggle OpenCode buffer" })
  vim.api.nvim_create_user_command("OpenCodeFocus", function() M.focus() end, { desc = "Focus OpenCode buffer" })
  vim.api.nvim_create_user_command("OpenCodeDiff", function() M.diff_review() end, { desc = "Review OpenCode diffs" })
  vim.api.nvim_create_user_command("OpenCodeAccept", function() M.diff_accept() end, { desc = "Accept OpenCode diffs" })
  vim.api.nvim_create_user_command("OpenCodeReject", function() M.diff_reject() end, { desc = "Reject OpenCode diffs" })
end

return M
