local dap = require("dap")

require("dap").adapters["pwa-node"] = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = {
		command = "js-debug",
		args = { "${port}" },
	},
}

require("dap").adapters["pwa-chrome"] = {
	type = "server",
	host = "localhost",
	port = "9222",
	executable = {
		command = "js-debug",
		args = { "9222" },
	},
}

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
