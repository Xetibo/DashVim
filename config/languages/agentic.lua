local M = {}

function M.restore_last_session()
  require("agentic")
  local registry = require("agentic.session_registry")
  local session = registry.get_session_for_tab_page()
  if not session then
    vim.notify("Agentic session unavailable", vim.log.levels.ERROR)
    return
  end

  local cwd = vim.fn.getcwd()
  session:on_session_ready(function(ready_session)
    ready_session.agent:list_sessions(cwd, function(result, err)
      vim.schedule(function()
        if registry.sessions[ready_session.tab_page_id] ~= ready_session then
          return
        end
        if err or not result then
          vim.notify("Failed to list Agentic sessions: " .. (err and err.message or "unknown error"), vim.log.levels.WARN)
          return
        end

        local latest
        for _, saved in ipairs(result.sessions or {}) do
          -- Exclude the empty session created while initializing this restore.
          if saved.sessionId ~= ready_session.session_id
            and (not saved.cwd or vim.fs.normalize(saved.cwd) == vim.fs.normalize(cwd))
            and (not latest or (saved.updatedAt or "") > (latest.updatedAt or "")) then
            latest = saved
          end
        end
        if not latest then
          vim.notify("No previous Agentic sessions found for this project", vim.log.levels.INFO)
          return
        end

        require("agentic.session_restore").restore_by_id(ready_session, latest.sessionId)
      end)
    end)
  end)
end

return M
