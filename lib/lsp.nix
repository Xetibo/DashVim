{lib, ...}: {
  mkLsp = {
    name,
    package,
    ft,
    formatterPkg ? null,
    formatterCommand ? null,
    formatterPreferLsp ? null,
  }
  : let
    lspLua =
      #-- TODO make this use an arg
      /*
      lua
      */
      ''
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities.textDocument.completion.completionItem.snippetSupport = true

          lspconfig.${name}.setup {
            capabilities = capabilities;
            on_attach = default_on_attach;
            cmd = ${
          if lib.isList package
          then lib.expToLua package
          else ''{"${package}/bin/${name}", ""}''
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
            require("conform").formatters_by_ft.${ft} = {
              "${formatterCommand}",
              ${
            if builtins.isNull formatterPreferLsp
            then ''lsp_format = "prefer"''
            else ''lsp_format = "${formatterPreferLsp}"''
          }
          }
        '';
  in
    lspLua + formatterLua;
}
