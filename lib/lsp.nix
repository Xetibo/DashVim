{lib, ...}: {
  mkLsp = {
    lspName,
    lspPackage,
    lspFt,
    lspArgs ? [],
    formatterPkg ? null,
    formatterCommand ? null,
    formatterPreferLsp ? null,
    adapterName ? null,
    adapterCommand ? null,
    adapterArgs ? null,
    pickerFn ? null,
  }
  : let
    splitArgs = args: "{" + (lib.lists.foldr (a: b: "\"" + a + "\"" + ", " + "\"" + b + "\"") "" args) + "},";
    normalizeLspName = name: lib.strings.concatStrings (lib.strings.splitString "-" name);
    lspLua =
      #-- TODO make this use an arg
      /*
      lua
      */
      ''
          local lspconfig = require('lspconfig')
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities.textDocument.completion.completionItem.snippetSupport = true

          lspconfig.${normalizeLspName lspName}.setup {
            capabilities = capabilities;
            on_attach = default_on_attach;
            cmd = ${
          if lib.isList lspPackage
          then lib.expToLua lspPackage
          else ''{ "${lspPackage}/bin/${lspName}" }''
        }
        }
      '';
    formatterLua =
      if builtins.isNull formatterCommand
      then ''''
      else
        /*
        lua
        */
        ''
            ${
            if builtins.isNull formatterPkg
            then ''''
            else
              /*
              lua
              */
              ''
                require("conform").formatters.${formatterCommand} = {
                  command = '${formatterPkg}/bin/${formatterCommand}',
                }
              ''
          }
            require("conform").formatters_by_ft.${lspFt} = {
              "${formatterCommand}",
              ${
            if builtins.isNull formatterPreferLsp
            then ''lsp_format = "prefer"''
            else ''lsp_format = "${formatterPreferLsp}"''
          }
          }
        '';
    dapLua =
      if builtins.isNull adapterName || builtins.isNull pickerFn
      then ''''
      else
        /*
        lua
        */
        ''
          local dap = require('dap')
          ${
            if builtins.isNull adapterCommand
            then ''''
            else
              /*
              lua
              */
              ''
                dap.adapters.${adapterName} = {
                    type = "executable",
                    command = "${adapterCommand}",
                    args = ${
                  if builtins.isNull adapterArgs
                  then ""
                  else (splitArgs adapterArgs)
                }
                }
              ''
          }
          dap.configurations.${lspFt} = {
                 {
                   type = "${adapterName}",
                   name = "Debug ${lspFt}",
                   request = "launch",
                   program = ${pickerFn},
                 },
          }
        '';
  in
    lspLua + formatterLua + dapLua;
}
