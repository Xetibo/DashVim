local dap = require("dap")

dap.adapters["pwa-node"] = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = {
		command = "js-debug",
		args = { "${port}" },
	},
}

dap.adapters["pwa-chrome"] = {
	type = "server",
	host = "localhost",
	port = "9222",
	executable = {
		command = "js-debug",
		args = { "9222" },
	},
}

dap.adapters["coreclr"] = {
	type = "executable",
	command = "netcoredbg",
	args = { "--interpreter=vscode" },
}

dap.adapters["rustlldb"] = {
	type = "executable",
	command = "rust-lldb",
	args = { "--interpreter=vscode" },
}

dap.adapters["lldb"] = {
	type = "executable",
	command = "lldb-dap",
	args = { "--interpreter=vscode" },
}

dap.configurations.cs = {
	{
		type = "coreclr",
		name = "Debug .Net",
		request = "launch",
		program = function()
			return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
		end,
	},
}
dap.configurations.fsharp = dap.configurations.cs

dap.configurations.typescript = {
	{
		type = "pwa-chrome",
		name = "Launch Chrome debug",
		request = "launch",
		url = "http://localhost:4200",
		sourceMaps = true,
		protocol = "inspector",
		port = 9222,
		webRoot = "${workspaceFolder}",
	},
	{
		type = "pwa-chrome",
		request = "launch",
		name = "Launch Current File (Typescript)",
		cwd = "${workspaceFolder}",
		runtimeArgs = { "--loader=ts-node/esm" },
		program = "${file}",
		runtimeExecutable = "node",
		sourceMaps = true,
		protocol = "inspector",
		outFiles = { "${workspaceFolder}/**/**/*", "!**/node_modules/**" },
		skipFiles = { "<node_internals>/**", "node_modules/**" },
		resolveSourceMapLocations = {
			"${workspaceFolder}/**",
			"!**/node_modules/**",
		},
	},
}
dap.configurations.javascript = dap.configurations.typescript

local rust_dap = vim.fn.getcwd()
local filename = ""
for w in rust_dap:gmatch("([^/]+)") do
	filename = w
end
dap.configurations.rust = {
	{
		type = "rustlldb",
		request = "launch",
		program = function()
			return rust_dap .. "/target/debug/" .. filename
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = true,
		terminal = "integrated",
	},
}

dap.configurations.cpp = {
	{
		name = "debug cpp",
		type = "lldb",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = true,
		terminal = "integrated",
	},
}
dap.configurations.c = dap.configurations.cpp
