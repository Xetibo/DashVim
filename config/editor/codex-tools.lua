local api = vim.api
local mcp = require("nvim-mcp").MCP
local M = {}

local function source_buffer(buf)
  return api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == ""
    and api.nvim_buf_get_name(buf) ~= "" and not vim.bo[buf].filetype:match("^agentic")
end

local function resolve(args)
  local buf = args.id
  if not buf and args.path then
    buf = vim.fn.bufadd(vim.fn.fnamemodify(args.path, ":p"))
    vim.fn.bufload(buf)
  end
  if not buf then
    buf = api.nvim_get_current_buf()
    if not source_buffer(buf) then
      buf = nil
      for _, win in ipairs(api.nvim_list_wins()) do
        local candidate = api.nvim_win_get_buf(win)
        if source_buffer(candidate) then
          assert(not buf or buf == candidate, "Multiple source buffers visible; specify id or path")
          buf = candidate
        end
      end
    end
  end
  assert(buf and source_buffer(buf), "Specify a named source buffer id or path")
  assert(api.nvim_buf_is_loaded(buf), "Source buffer is not loaded")
  return buf
end

local function snapshot(args)
  local buf = resolve(args)
  local count = api.nvim_buf_line_count(buf)
  local cursor
  for _, win in ipairs(api.nvim_list_wins()) do
    if api.nvim_win_get_buf(win) == buf then
      cursor = api.nvim_win_get_cursor(win)
      break
    end
  end
  local start = args.start or math.max(0, (cursor and cursor[1] or 1) - 41)
  local finish = args["end"] or math.min(count, start + 80)
  assert(start <= finish and finish <= count and finish - start <= 400, "Invalid range; read at most 400 lines")
  local result = {
    id = buf, path = api.nvim_buf_get_name(buf), changedtick = api.nvim_buf_get_changedtick(buf),
    start = start, ["end"] = finish, line_count = count,
    lines = api.nvim_buf_get_lines(buf, start, finish, true), cursor = cursor,
  }
  local first, last = api.nvim_buf_get_mark(buf, "<"), api.nvim_buf_get_mark(buf, ">")
  if first[1] > 0 and last[1] > 0 then
    result.selection = { start_line = first[1] - 1, end_line = last[1], start_col = first[2], end_col = last[2] }
  end
  if args.diagnostics then
    result.diagnostics = {}
    for _, diagnostic in ipairs(vim.diagnostic.get(buf)) do
      if diagnostic.lnum >= start and diagnostic.lnum < finish then
        table.insert(result.diagnostics, {
          message = diagnostic.message, source = diagnostic.source or "", severity = diagnostic.severity,
          lnum = diagnostic.lnum, col = diagnostic.col,
        })
        if #result.diagnostics == 100 then break end
      end
    end
  end
  return result
end

local function edit(args)
  local buf = resolve({ id = args.id })
  local root = assert(vim.uv.fs_realpath(vim.fn.getcwd()), "Workspace root is unavailable")
  local name = api.nvim_buf_get_name(buf)
  local path = vim.uv.fs_realpath(name)
  if not path then
    assert(not vim.uv.fs_lstat(name), "Edit target cannot be resolved")
    local parent = assert(vim.uv.fs_realpath(vim.fn.fnamemodify(name, ":h")), "Parent directory must exist")
    path = parent .. "/" .. vim.fn.fnamemodify(name, ":t")
  end
  assert(path:sub(1, #root + 1) == root .. "/", "Edit target is outside the editor workspace")
  local relative = path:sub(#root + 2)
  for segment in relative:gmatch("[^/]+") do
    assert(segment ~= ".git" and segment ~= ".codex", "Edit target is a protected path")
  end
  assert(api.nvim_buf_get_changedtick(buf) == args.changedtick, "Buffer changed since read; read again before editing")
  assert(args.start <= args["end"] and args["end"] <= api.nvim_buf_line_count(buf), "Invalid edit range")
  local current = api.nvim_buf_get_lines(buf, args.start, args["end"], true)
  assert(vim.deep_equal(current, args.expected), "Expected text does not match; read again before editing")
  api.nvim_buf_set_lines(buf, args.start, args["end"], true, args.replacement)
  local result = { id = buf, edited = true, saved = false, changedtick = api.nvim_buf_get_changedtick(buf) }
  if args.save ~= false then
    local ok, err = pcall(api.nvim_buf_call, buf, function() vim.cmd("noautocmd update") end)
    result.saved = ok and not vim.bo[buf].modified
    if not result.saved then
      return mcp.error("WRITE_FAILED", "Edit applied but save failed; buffer remains modified: " .. tostring(err), result)
    end
  end
  return mcp.success(result)
end

local function find_files(args)
  local root = assert(vim.uv.fs_realpath(vim.fn.fnamemodify(args.directory or vim.fn.getcwd(), ":p")), "Directory not found")
  local pattern = vim.regex(vim.fn.glob2regpat(args.pattern))
  local excluded = { [".git"] = true, [".direnv"] = true, node_modules = true, bin = true, obj = true }
  local paths, examined = {}, 0
  local truncated = false
  local function visit(directory, depth)
    local scanner = vim.uv.fs_scandir(directory)
    if not scanner then return end
    while true do
      local name, kind = vim.uv.fs_scandir_next(scanner)
      if not name then break end
      examined = examined + 1
      if examined > 4096 or #paths >= (args.limit or 32) then truncated = true; return end
      local path = directory .. "/" .. name
      if kind == "file" and pattern:match_str(name) then table.insert(paths, path) end
      if kind == "directory" and depth > 0 and not excluded[name] then visit(path, depth - 1) end
      if truncated then return end
    end
  end
  visit(root, args.depth or 2)
  return mcp.success({ paths = paths, truncated = truncated, examined = examined })
end

local integer = { type = "integer", minimum = 0 }
local buffer_fields = {
  id = { type = "integer", minimum = 1 }, path = { type = "string", minLength = 1 },
  start = integer, ["end"] = integer, diagnostics = { type = "boolean" },
}
local function schema(properties, required)
  properties = vim.deepcopy(properties)
  properties.connection_id = { type = "string" }
  return { type = "object", properties = properties, required = required or {}, additionalProperties = false }
end

function M.tools()
  return {
    editor_context = {
      description = "Read live source context, path, changedtick, cursor/selection and optional existing diagnostics. Zero-based ranges, end exclusive; at most 400 lines. Specify id/path when chat has focus.",
      parameters = schema(buffer_fields),
      handler = function(args) return mcp.success(snapshot(args)) end,
    },
    read_buffers = {
      description = "Batch live reads of explicit buffer ids or paths and small zero-based start/end-exclusive ranges. Returns lines and changedticks, including unsaved text.",
      parameters = schema({ buffers = { type = "array", minItems = 1, maxItems = 16,
        items = schema(buffer_fields, { "start", "end" }) } }, { "buffers" }),
      handler = function(args)
        local results = {}
        for _, buffer in ipairs(args.buffers) do table.insert(results, snapshot(buffer)) end
        return mcp.success(results)
      end,
    },
    edit_buffer = {
      description = "Atomically replace source lines after changedtick AND exact expected-lines checks. Native undo; save defaults true using noautocmd update. Workspace files only. Returns write failures without discarding edits.",
      parameters = schema({
        id = { type = "integer", minimum = 1 }, changedtick = integer, start = integer, ["end"] = integer,
        expected = { type = "array", items = { type = "string" } },
        replacement = { type = "array", items = { type = "string" } }, save = { type = "boolean" },
      }, { "id", "changedtick", "start", "end", "expected", "replacement" }),
      handler = edit,
    },
    find_files = {
      description = "Bounded file-name glob discovery within a narrow directory. Skips dependency/build/VCS directories and symlinks. Returns paths and truncation status; no shell or file reads.",
      parameters = schema({ directory = { type = "string" }, pattern = { type = "string", minLength = 1 },
        depth = { type = "integer", minimum = 0, maximum = 5 }, limit = { type = "integer", minimum = 1, maximum = 64 },
      }, { "pattern" }),
      handler = find_files,
    },
  }
end

return M
