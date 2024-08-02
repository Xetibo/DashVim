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
    };
  };
  extraConfigLua = ''
    local_border = "rounded"
  '';
}

