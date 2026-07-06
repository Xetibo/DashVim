local M = {}

M.bufnr = nil
M.winnr = nil
M.job_id = nil
M.config_dir = nil
M.default_mode = "copilot"
M.current_mode = "copilot"

local function config_dir()
  if M.config_dir then
    return M.config_dir
  end
  local xdg = vim.env.XDG_CONFIG_HOME
  if xdg and xdg ~= "" then
    M.config_dir = xdg .. "/opencode"
  else
    M.config_dir = vim.fn.expand("~/.config/opencode")
  end
  return M.config_dir
end

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

  M.winnr = vim.api.nvim_open_win(buf, true, {
    split = "right",
  })
end

--- Create a session-scoped temp config directory for opencode.
--- The directory mirrors ~/.config/opencode/ but with the mode-specific
--- oh-my-openagent.jsonc copied in. Returns base path to use as XDG_CONFIG_HOME.
local function prepare_session_config()
  local real_cfg = config_dir()
  local id = vim.fn.tempname():match("[^/]+$")
  local base = "/tmp/opencode-nvim-" .. id
  local oc_dir = base .. "/opencode"

  vim.fn.mkdir(oc_dir, "p")

  -- Symlink shared config files (opencode.json, tui.json)
  for _, name in ipairs({ "opencode.json", "tui.json" }) do
    local src = real_cfg .. "/" .. name
    local dst = oc_dir .. "/" .. name
    if vim.fn.filereadable(src) == 1 then
      vim.fn.system({ "ln", "-s", src, dst })
    end
  end

  -- Symlink themes directory
  local themes_src = real_cfg .. "/themes"
  local themes_dst = oc_dir .. "/themes"
  if vim.fn.isdirectory(themes_src) == 1 then
    vim.fn.system({ "ln", "-s", themes_src, themes_dst })
  end

  -- Copy mode-specific agent config (the per-session part)
  local function resolve_mode_config(mode)
    local p = real_cfg .. "/oh-my-openagent-" .. mode .. ".jsonc"
    if vim.fn.filereadable(p) == 1 then
      return p
    end
    return nil
  end

  local mode_src = resolve_mode_config(M.current_mode)
    or resolve_mode_config(M.default_mode)
    or resolve_mode_config("copilot")

  if mode_src then
    vim.fn.writefile(vim.fn.readfile(mode_src), oc_dir .. "/oh-my-openagent.jsonc")
  else
    vim.notify("No oh-my-openagent config found for any mode", vim.log.levels.ERROR)
  end

  return base
end

local function start_terminal(buf)
  if M.job_id then
    return
  end

  vim.api.nvim_set_current_buf(buf)

  local config_base = prepare_session_config()

  M.job_id = vim.fn.termopen({ "opencode", vim.fn.getcwd() }, {
    env = {
      OPENTUI_GRAPHICS = "0",
      XDG_CONFIG_HOME = config_base,
    },
    on_exit = function()
      M.job_id = nil
      M.bufnr = nil
      if vim.fn.isdirectory(config_base) == 1 then
        vim.fn.system({ "rm", "-rf", config_base })
      end
    end,
  })
end

function M.get_mode()
  return M.current_mode
end

function M.toggle_mode()
  local next_mode = M.current_mode == "copilot" and "free" or "copilot"
  M.set_mode(next_mode)
end

function M.set_mode(mode)
  if mode ~= "copilot" and mode ~= "free" then
    vim.notify("Usage: OpenCodeAgentMode copilot|free", vim.log.levels.WARN)
    return
  end

  M.current_mode = mode

  -- Kill running opencode if any. Next toggle recreates session config with new mode.
  if M.job_id then
    vim.fn.jobstop(M.job_id)
    M.job_id = nil
    if M.winnr and vim.api.nvim_win_is_valid(M.winnr) then
      vim.api.nvim_win_close(M.winnr, true)
      M.winnr = nil
    end
    M.bufnr = nil
  end

  vim.notify("OpenCode agent mode: " .. mode, vim.log.levels.INFO)
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

function M.setup(opts)
  opts = opts or {}

  -- Resolve default mode from Nix config, fallback to copilot
  M.default_mode = opts.default_model_mode or "copilot"
  M.current_mode = M.default_mode

  local ok, lualine = pcall(require, "lualine")
  if ok then
    local cfg = lualine.get_config() or {}
    cfg.sections = cfg.sections or {}
    cfg.sections.lualine_y = cfg.sections.lualine_y or {}
    table.insert(cfg.sections.lualine_y, 1, {
      function()
        local m = require("opencode").get_mode()
        return "󰚩 " .. m
      end,
      color = { fg = "#89b4fa" },
      padding = { left = 1, right = 0 },
    })
    lualine.setup(cfg)
  end

  vim.api.nvim_create_user_command("OpenCode", function() M.toggle() end, { desc = "Toggle OpenCode buffer" })
  vim.api.nvim_create_user_command("OpenCodeFocus", function() M.focus() end, { desc = "Focus OpenCode buffer" })
  vim.api.nvim_create_user_command("OpenCodeDiff", function() M.diff_review() end, { desc = "Review OpenCode diffs" })
  vim.api.nvim_create_user_command("OpenCodeAccept", function() M.diff_accept() end, { desc = "Accept OpenCode diffs" })
  vim.api.nvim_create_user_command("OpenCodeReject", function() M.diff_reject() end, { desc = "Reject OpenCode diffs" })
  vim.api.nvim_create_user_command("OpenCodeAgentMode",
    function(t)
      local m = t.args:match("%S+")
      M.set_mode(m)
    end,
    {
      nargs = 1,
      complete = function() return { "copilot", "free" } end,
      desc = "Switch oh-my-openagent model mode (copilot|free)",
    }
  )

  vim.api.nvim_create_user_command("OpenCodeReview", function()
    local review = require("opencode.review")
    review.open()
  end, { desc = "Open code review session for agent changes" })

  vim.api.nvim_create_user_command("OpenCodeReviewComplete", function()
    local review = require("opencode.review")
    review.complete()
  end, { desc = "Complete review session and send comments to agent" })
end

return M
