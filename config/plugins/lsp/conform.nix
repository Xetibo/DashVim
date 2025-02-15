{pkgs, ...}: {
  extraPackages = with pkgs; [
    prettierd
    black
    stylua
    alejandra
    yamllint
    yamlfmt
  ];
  plugins.conform-nvim = {
    enable = true;
    settings = {
      notify_on_error = true;
      formatters_by_ft = {
        html = [
          [
            "prettierd"
            "prettier"
          ]
        ];
        css = [
          [
            "prettierd"
            "prettier"
          ]
        ];
        javascript = [
          [
            "prettierd"
            "prettier"
          ]
        ];
        javascriptreact = [
          [
            "prettierd"
            "prettier"
          ]
        ];
        typescript = [
          [
            "prettierd"
            "prettier"
          ]
        ];
        typescriptreact = [
          [
            "prettierd"
            "prettier"
          ]
        ];
        fsharp = ["fantomas"];
        python = ["black"];
        lua = ["stylua"];
        nix = ["alejandra"];
        markdown = [
          [
            "prettierd"
            "prettier"
          ]
        ];
        yaml = [
          "yamllint"
          "yamlfmt"
        ];
        php = [
          "prettierd"
          "prettier"
        ];
      };
    };
  };
}
