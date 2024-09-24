{
  plugins = {
    nix.enable = true;
    neotest = {
      enable = true;
      adapters = {
        dotnet = {
          # fsharp doesn't work, cool, thanks
          enable = false;
          settings = {
            single_file_support = true;
            dap = {
              args = {
                justMyCode = false;
              };
              adapter_name = "coreclr";
            };
          };
        };
        elixir.enable = true;
        go.enable = true;
        gradle.enable = true;
        rust.enable = true;
        python.enable = true;
        zig.enable = true;
        playwright.enable = true;
        haskell.enable = true;
        java.enable = true;
        bash.enable = true;
        dart.enable = true;
        deno.enable = true;
      };
    };
    lsp-format = {
      enable = true;
    };
    lsp-lines = {
      enable = true;
    };
    lsp-status = {
      enable = true;
    };
    lsp = {
      enable = true;
      inlayHints = true;
      preConfig = # lua
        ''
          local border = {
                {"🭽", "FloatBorder"},
                {"▔", "FloatBorder"},
                {"🭾", "FloatBorder"},
                {"▕", "FloatBorder"},
                {"🭿", "FloatBorder"},
                {"▁", "FloatBorder"},
                {"🭼", "FloatBorder"},
                {"▏", "FloatBorder"},
          }
          local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
          function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
            opts = opts or {}
            opts.border = border 
            return orig_util_open_floating_preview(contents, syntax, opts, ...)
          end
        '';
      servers = {
        bashls.enable = true;
        clangd.enable = true;
        cmake.enable = true;
        dartls.enable = true;
        elmls.enable = true;
        dhall-lsp-server.enable = true;
        elixirls.enable = true;
        gopls.enable = true;
        # installed by haskell-tools
        # hls.enable = true;
        html.enable = true;
        htmx.enable = true;
        jsonls.enable = false;
        cssls.enable = false;
        julials.enable = true;
        kotlin-language-server.enable = true;
        java-language-server.enable = true;
        lua-ls.enable = true;
        # i hate this server
        #marksman.enable = true;
        nushell.enable = true;
        ocamllsp.enable = true;
        omnisharp.enable = true;
        pyright.enable = true;
        ruby-lsp.enable = true;
        # installed by rustacean
        # rust-analyzer = {
        #   enable = true;
        #   installCargo = false;
        #   installRustc = false;
        # };
        svelte.enable = true;
        taplo.enable = true;
        sqls.enable = true;
        tinymist.enable = true;
        ts-ls.enable = true;
        vuels.enable = true;
        yamlls.enable = true;
        zls.enable = true;
        texlab.enable = true;
        tailwindcss.enable = true;
        nixd = {
          enable = true;
        };
        #nil-ls = {
        #  enable = true;
        #  settings.formatting.command = [
        #    "nixfmt"
        #  ];
        #};
        #fsautocomplete = {
        #  enable = true;
        #  cmd = [
        #    "fsautocomplete"
        #    "--adaptive-lsp-server-enabled"
        #    "--project-graph-enabled"
        #    "--use-fcs-transparent-compiler"
        #  ];
        #  #rootDir = "require('lspconfig').util.root_pattern('*.sln', '.git')";
        #  extraOptions = {
        #    init_options = {
        #      AutomaticWorkspaceInit = true;
        #    };
        #  };
        #  settings = {
        #    FSharp = {
        #      AutomaticWorkspaceInit = true;
        #      EnableReferenceCodeLens = true;
        #      ExternalAutocomplete = false;
        #      InterfaceStubGeneration = true;
        #      InterfaceStubGenerationMethodBody = ''failwith "Not Implemented"'';
        #      InterfaceStubGenerationObjectIdentifier = "this";
        #      Linter = true;
        #      RecordStubGeneration = true;
        #      RecordStubGenerationBody = ''failwith "Not Implemented"'';
        #      ResolveNamespaces = true;
        #      SimplifyNameAnalyzer = true;
        #      UnionCaseStubGeneration = true;
        #      UnionCaseStubGenerationBody = ''failwith "nimp"'';
        #      UnusedDeclarationsAnalyzer = true;
        #      UnusedOpensAnalyzer = true;
        #      UseSdkScripts = true;
        #      keywordsAutocomplete = true;
        #    };
        #  };
        #};
      };
    };
  };
  extraConfigLua = ''
    local_border = "rounded"
  '';
}
