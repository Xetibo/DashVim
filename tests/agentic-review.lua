local function check(value, message)
  assert(value, message)
end

for key, method in pairs({ ar = "open", an = "add_comment", ae = "complete_agentic", ap = "restore_last_session" }) do
  local mapping = vim.fn.maparg(vim.g.mapleader .. "a" .. key:sub(2), "n", false, true)
  check(mapping.rhs and mapping.rhs:find(method, 1, true), "Missing keymap: " .. key)
end

local review = require("opencode.review")
local restore = require("dashvim.agentic")
local registry = require("agentic.session_registry")
local original_new = registry.new_session
local original_get = registry.get_session_for_tab_page
local original_sessions = registry.sessions
registry.sessions = {}

local root = vim.fn.tempname()
local cwd = vim.fn.getcwd()
vim.fn.mkdir(root, "p")
vim.cmd.cd(root)
vim.fn.writefile({ "original source" }, root .. "/sample.lua")
vim.cmd.edit(root .. "/sample.lua")
vim.api.nvim_create_user_command("DiffviewOpen", function() end, { force = true })

review.open()
check(require("lualine").get_config().sections.lualine_a[1].fmt("NORMAL") == "REVIEW", "Review statusline missing")
review.add_comment()
vim.api.nvim_buf_set_lines(review._comment_popover.buf, 0, -1, false, { "Fix this line" })
review._confirm_popover()
vim.cmd.stopinsert()
vim.wait(50)
check(vim.fn.readfile(root .. "/sample.lua")[1] == "original source", "Comment modified source")

local ready_callback
local sent_prompt
local tab = vim.api.nvim_get_current_tabpage()
local session = {
  tab_page_id = tab,
  session_id = "current",
  widget = { show = function() end },
  on_session_ready = function(_, callback) ready_callback = callback end,
  _handle_input_submit = function(_, prompt) sent_prompt = prompt; return true end,
}
registry.new_session = function() registry.sessions[tab] = session; return session end
review.complete_agentic()
check(not sent_prompt and review.current_session, "Review cleared before session ready")
ready_callback(session)
check(sent_prompt and sent_prompt:find("1 comments", 1, true), "Review prompt not submitted")
check(not review.current_session and not vim.g.in_review_session, "Review not finalized")
check(require("lualine").get_config().sections.lualine_a[1].fmt("NORMAL") == "NORMAL", "Review statusline not reset")
local files = vim.fn.glob(root .. "/.omo/review-*.json", false, true)
local payload = vim.json.decode(table.concat(vim.fn.readfile(files[1]), "\n"))
check(payload.files[1].path == "sample.lua", "Wrong review path")
check(payload.files[1].comments[1].comment == "Fix this line", "Comment missing from JSON")

review.open()
review.comments[root .. "/sample.lua"] = { { line = 1, comment = "Retry this" } }
session._handle_input_submit = function() return false end
review.complete_agentic()
ready_callback(session)
check(review.current_session and vim.g.in_review_session, "Failed submission lost review")
registry.new_session = function() return nil end
review.complete_agentic()
check(review.current_session, "Failed session creation lost review")

local loaded
session.chat_history = { messages = {} }
session.load_acp_session = function(_, id) loaded = id end
session.agent = {
  when_ready = function(_, callback) callback() end,
  list_sessions = function(_, requested_cwd, callback)
    check(requested_cwd == root, "Restore queried wrong project")
    callback({ sessions = {
      { sessionId = "older", updatedAt = "2026-01-01T00:00:00Z", cwd = root },
      { sessionId = "other-project", updatedAt = "2026-10-05T00:00:00Z", cwd = "/other" },
      { sessionId = "latest", updatedAt = "2026-09-01T00:00:00Z", cwd = root },
      { sessionId = "current", updatedAt = "2026-10-05T00:00:00Z", cwd = root },
    } }, nil)
  end,
}
registry.get_session_for_tab_page = function() return session end
restore.restore_last_session()
ready_callback(session)
vim.wait(100, function() return loaded ~= nil end)
check(loaded == "latest", "Restore did not choose newest previous project session")

loaded = nil
session.chat_history.messages = { { text = "Existing conversation" } }
local original_select = vim.ui.select
vim.ui.select = function(_, _, callback) callback("Cancel") end
restore.restore_last_session()
ready_callback(session)
vim.wait(50)
check(not loaded, "Restore ignored upstream conflict cancellation")
vim.ui.select = original_select

registry.new_session = original_new
registry.get_session_for_tab_page = original_get
registry.sessions = original_sessions
vim.cmd.cd(cwd)
vim.fn.delete(root, "rf")
print("Agentic review/session checks passed")
