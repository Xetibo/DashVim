{
  plugins = {
    neotest = {
      enable = true;
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
      servers = {
        bashls.enable = true;
        clangd.enable = true;
        cmake.enable = true;
        cssls.enable = true;
        dartls.enable = true;
        elmls.enable = true;
        dhall-lsp-server.enable = true;
        elixirls.enable = true;
        gopls.enable = true;
        # installed by haskell-tools
        # hls.enable = true;
        html.enable = true;
        htmx.enable = true;
        jsonls.enable = true;
        julials.enable = true;
        kotlin-language-server.enable = true;
        java-language-server.enable = true;
        lua-ls.enable = true;
        marksman.enable = true;
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
        tsserver.enable = true;
        vuels.enable = true;
        yamlls.enable = true;
        zls.enable = true;
        texlab.enable = true;
        tailwindcss.enable = true;
        nixd.enable = true;
        fsautocomplete.enable = true;
      };
      keymaps = {
        silent = true;
        lspBuf = {
          "<leader>ca" = {
            action = "definition";
            desc = "Goto Definition";
          };
          "<leader>cs" = {
            action = "references";
            desc = "Goto References";
          };
          "<leader>cA" = {
            action = "declaration";
            desc = "Goto Declaration";
          };
          "<leader>cf" = {
            action = "implementation";
            desc = "Goto Implementation";
          };
          "<leader>cd" = {
            action = "type_definition";
            desc = "Type Definition";
          };
          "<leader>ce" = {
            action = "hover";
            desc = "Hover";
          };
          "<leader>cw" = {
            action = "workspace_symbol";
            desc = "Workspace Symbol";
          };
          "<leader>cr" = {
            action = "rename";
            desc = "Rename";
          };
        };
        diagnostic = {
          "<leader>cld" = {
            action = "open_float";
            desc = "Line Diagnostics";
          };
          "<leader>cn" = {
            action = "goto_next";
            desc = "Next Diagnostic";
          };
          "<leader>cp" = {
            action = "goto_prev";
            desc = "Previous Diagnostic";
          };
        };
      };
    };
  };
  extraConfigLua = ''
    local_border = "rounded"
  '';
}

