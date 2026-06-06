{
  lib,
  pkgs,
}: let
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.meta) getExe getExe';

  overridePriority = 90;

  rustString = builtins.toJSON;
  rustList = values: "[${lib.concatMapStringsSep ", " rustString values}]";

  toolConfigRust = pkgs.writeText "dashvim-project-tool-config.rs" ''
    use super::Tool;

    pub static TOOLS: &[Tool] = &[
      ${lib.concatStringsSep "\n  " (lib.mapAttrsToList (name: spec: ''
        Tool {
          name: ${rustString name},
          commands: &${rustList (spec.commands or [name])},
          fallback: ${rustString spec.fallback},
        },
      '')
      toolSpecs)}
    ];
  '';

  resolver = pkgs.stdenv.mkDerivation {
    pname = "dashvim-project-tool-resolver";
    version = "1.0.0";

    nativeBuildInputs = [pkgs.rustc];

    dontUnpack = true;

    buildPhase = ''
      runHook preBuild

      mkdir -p src
      cp ${./toolchain/dashvim_project_tool.rs} src/main.rs
      cp ${toolConfigRust} src/tool_config.rs
      rustc --edition=2021 -C opt-level=2 src/main.rs -o dashvim-project-tool

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      install -m 755 dashvim-project-tool $out/bin/dashvim-project-tool

      ${lib.concatMapStringsSep "\n" (name: ''
        ln -s dashvim-project-tool $out/bin/dashvim-project-tool-${name}
      '') (builtins.attrNames toolSpecs)}

      runHook postInstall
    '';
  };

  valaLanguageServer = pkgs.symlinkJoin {
    name = "vala-language-server-wrapper";
    paths = [pkgs.vala-language-server];
    meta.mainProgram = "vala-language-server";
    buildInputs = [pkgs.makeBinaryWrapper];
    postBuild = "wrapProgram $out/bin/vala-language-server --prefix PATH : ${pkgs.uncrustify}/bin";
  };

  ruffCheck = pkgs.writeShellApplication {
    name = "ruff-check";
    runtimeInputs = [pkgs.ruff];
    text = ''
      ruff check --fix --exit-zero -
    '';
  };

  mdformat = pkgs.python313Packages.python.withPackages (pythonPackages:
    with pythonPackages; [
      mdformat
      mdformat-gfm
      mdformat-frontmatter
      mdformat-footnote
    ]);

  toolSpecs = {
    alejandra = {fallback = getExe pkgs.alejandra;};
    asmfmt = {fallback = getExe pkgs.asmfmt;};
    "asm-lsp" = {fallback = getExe pkgs.asm-lsp;};
    "astro-language-server" = {fallback = getExe pkgs.astro-language-server;};
    astyle = {fallback = getExe pkgs.astyle;};
    "basedpyright-langserver" = {fallback = getExe' pkgs.basedpyright "basedpyright-langserver";};
    "bash-language-server" = {fallback = getExe pkgs.bash-language-server;};
    biome = {fallback = getExe pkgs.biome;};
    black = {fallback = getExe pkgs.black;};
    ccls = {fallback = getExe pkgs.ccls;};
    "clang-format" = {fallback = getExe' pkgs.clang-tools "clang-format";};
    clangd = {fallback = getExe' pkgs.clang-tools "clangd";};
    "clojure-lsp" = {fallback = getExe pkgs.clojure-lsp;};
    "csharp-ls" = {
      commands = ["csharp-ls" "csharp_ls"];
      fallback = getExe pkgs.csharp-ls;
    };
    csharpier = {fallback = getExe pkgs.csharpier;};
    cue = {fallback = getExe pkgs.cue;};
    dart = {fallback = getExe pkgs.dart;};
    deadnix = {fallback = getExe pkgs.deadnix;};
    deno = {fallback = getExe pkgs.deno;};
    "docker-language-server" = {fallback = getExe pkgs.docker-language-server;};
    "elixir-ls" = {fallback = getExe pkgs.elixir-ls;};
    "elm-language-server" = {fallback = getExe pkgs.elmPackages.elm-language-server;};
    "emmet-ls" = {fallback = getExe pkgs.emmet-ls;};
    eslint_d = {fallback = getExe pkgs.eslint_d;};
    fantomas = {fallback = getExe pkgs.fantomas;};
    "fish-lsp" = {fallback = getExe pkgs.fish-lsp;};
    fsautocomplete = {fallback = getExe pkgs.fsautocomplete;};
    gleam = {fallback = getExe pkgs.gleam;};
    glsl_analyzer = {fallback = getExe pkgs.glsl_analyzer;};
    gofmt = {fallback = "${pkgs.go}/bin/gofmt";};
    gofumpt = {fallback = getExe pkgs.gofumpt;};
    golangci-lint = {fallback = getExe pkgs.golangci-lint;};
    golines = {fallback = "${pkgs.golines}/bin/golines";};
    gopls = {fallback = getExe pkgs.gopls;};
    "haskell-language-server" = {fallback = getExe pkgs.haskell-language-server;};
    harper = {fallback = getExe pkgs.harper;};
    "helm-ls" = {fallback = getExe pkgs.helm-ls;};
    htmlhint = {fallback = getExe pkgs.htmlhint;};
    indent = {fallback = getExe pkgs.indent;};
    intelephense = {fallback = getExe pkgs.intelephense;};
    isort = {fallback = getExe pkgs.isort;};
    "jdt-language-server" = {
      commands = ["jdtls" "jdt-language-server"];
      fallback = getExe pkgs.jdt-language-server;
    };
    "jq-lsp" = {fallback = getExe pkgs.jq-lsp;};
    jqfmt = {fallback = getExe pkgs.jqfmt;};
    jsonfmt = {fallback = getExe pkgs.jsonfmt;};
    ktlint = {fallback = getExe pkgs.ktlint;};
    "kotlin-language-server" = {fallback = getExe pkgs.kotlin-language-server;};
    luacheck = {fallback = getExe pkgs.luajitPackages.luacheck;};
    "lua-language-server" = {fallback = getExe pkgs.lua-language-server;};
    markdownlint-cli2 = {fallback = getExe pkgs.markdownlint-cli2;};
    markdown-oxide = {fallback = getExe pkgs.markdown-oxide;};
    marksman = {fallback = getExe pkgs.marksman;};
    mdformat = {fallback = getExe' mdformat "mdformat";};
    mix = {fallback = "${pkgs.elixir}/bin/mix";};
    mypy = {fallback = getExe' pkgs.mypy "mypy";};
    nasmfmt = {fallback = getExe pkgs.nasmfmt;};
    neocmakelsp = {fallback = getExe pkgs.neocmakelsp;};
    nil = {fallback = getExe pkgs.nil;};
    nixd = {fallback = getExe pkgs.nixd;};
    nixfmt = {fallback = getExe pkgs.nixfmt;};
    ngserver = {fallback = "${pkgs.angular-language-server}/bin/ngserver";};
    omnisharp = {fallback = getExe pkgs.omnisharp-roslyn;};
    php-cs-fixer = {fallback = "${pkgs.php84Packages.php-cs-fixer}/bin/php-cs-fixer";};
    phan = {fallback = getExe pkgs.php85Packages.phan;};
    phpactor = {fallback = getExe pkgs.phpactor;};
    phpantom = {fallback = getExe pkgs.phpantom-lsp;};
    phpstan = {fallback = getExe pkgs.phpstan;};
    prettierd = {fallback = getExe pkgs.prettierd;};
    prettier = {fallback = getExe pkgs.prettier;};
    "pylsp" = {
      commands = ["pylsp" "python-lsp-server"];
      fallback = getExe pkgs.python3Packages.python-lsp-server;
    };
    pyrefly = {fallback = getExe pkgs.pyrefly;};
    "pyright-langserver" = {fallback = getExe' pkgs.pyright "pyright-langserver";};
    rubocop = {fallback = getExe pkgs.rubyPackages.rubocop;};
    "ruby-lsp" = {fallback = getExe pkgs.ruby-lsp;};
    roslyn-ls = {fallback = getExe pkgs.roslyn-ls;};
    ruff = {fallback = getExe pkgs.ruff;};
    "ruff-check" = {fallback = getExe ruffCheck;};
    rumdl = {fallback = getExe pkgs.rumdl;};
    "rust-analyzer" = {fallback = getExe pkgs.rust-analyzer;};
    rustfmt = {fallback = getExe pkgs.rustfmt;};
    selene = {fallback = getExe pkgs.selene;};
    shfmt = {fallback = getExe pkgs.shfmt;};
    shellcheck = {fallback = getExe pkgs.shellcheck;};
    solargraph = {fallback = getExe pkgs.rubyPackages.solargraph;};
    sqlfluff = {fallback = getExe pkgs.sqlfluff;};
    sqls = {fallback = getExe pkgs.sqls;};
    sqruff = {fallback = getExe pkgs.sqruff;};
    statix = {fallback = getExe pkgs.statix;};
    stylua = {fallback = getExe pkgs.stylua;};
    superhtml = {fallback = getExe pkgs.superhtml;};
    "svelte-language-server" = {fallback = getExe pkgs.svelte-language-server;};
    "tailwindcss-language-server" = {fallback = getExe pkgs.tailwindcss-language-server;};
    terraform = {fallback = getExe pkgs.terraform;};
    terraform-ls = {fallback = getExe pkgs.terraform-ls;};
    tinymist = {fallback = getExe pkgs.tinymist;};
    tofu = {
      commands = ["tofu" "opentofu"];
      fallback = getExe pkgs.opentofu;
    };
    tofu-ls = {fallback = getExe pkgs.tofu-ls;};
    ty = {fallback = getExe pkgs.ty;};
    typescript-go = {
      commands = ["tsgo" "typescript-go"];
      fallback = getExe pkgs.typescript-go;
    };
    typescript-language-server = {fallback = getExe pkgs.typescript-language-server;};
    typstyle = {fallback = getExe pkgs.typstyle;};
    "vala-language-server" = {fallback = getExe valaLanguageServer;};
    "vscode-css-language-server" = {fallback = getExe' pkgs.vscode-langservers-extracted "vscode-css-language-server";};
    "vscode-json-language-server" = {fallback = getExe' pkgs.vscode-langservers-extracted "vscode-json-language-server";};
    wgsl-analyzer = {fallback = getExe pkgs.wgsl-analyzer;};
    yaml-language-server = {fallback = getExe pkgs.yaml-language-server;};
    yamlfmt = {fallback = getExe pkgs.yamlfmt;};
    yamllint = {fallback = getExe pkgs.yamllint;};
    zls = {fallback = getExe pkgs.zls;};
    zuban = {fallback = getExe pkgs.zuban;};
  };

  toolBins = mapAttrs (name: _: "${resolver}/bin/dashvim-project-tool-${name}") toolSpecs;

  bin = name: toolBins.${name};

  mkCmd = tool: args: [(bin tool)] ++ args;
  mkLsp = tool: args: {
    cmd = lib.mkOverride overridePriority (mkCmd tool args);
  };
in rec {
  inherit bin overridePriority;

  lspServers = {
    angular = mkLsp "ngserver" ["--stdio"];
    angular-language-server = mkLsp "ngserver" ["--stdio"];
    asm-lsp = mkLsp "asm-lsp" [];
    astro-language-server = mkLsp "astro-language-server" ["--stdio"];
    basedpyright = mkLsp "basedpyright-langserver" ["--stdio"];
    bash-language-server = mkLsp "bash-language-server" ["start"];
    ccls = mkLsp "ccls" [];
    clangd = mkLsp "clangd" [];
    clojure-lsp = mkLsp "clojure-lsp" [];
    csharp_ls = {
      cmd = lib.mkOverride overridePriority (mkLuaInline
        /*
        lua
        */
        ''
          function(dispatchers, config)
            return vim.lsp.rpc.start({ '${bin "csharp-ls"}', '--features', 'razor-support', '--features', 'metadata-uris' }, dispatchers, {
              cwd = config.cmd_cwd or config.root_dir,
              env = config.cmd_env,
              detached = config.detached,
            })
          end
        '');
    };
    cue = mkLsp "cue" ["lsp"];
    dart = mkLsp "dart" ["language-server" "--protocol=lsp"];
    deno = mkLsp "deno" ["lsp"];
    docker-language-server = mkLsp "docker-language-server" ["start" "--stdio"];
    elixir-ls = mkLsp "elixir-ls" [];
    elm-language-server = mkLsp "elm-language-server" [];
    emmet-ls = mkLsp "emmet-ls" ["--stdio"];
    fish-lsp = mkLsp "fish-lsp" ["start"];
    fsautocomplete = mkLsp "fsautocomplete" ["--adaptive-lsp-server-enabled"];
    gleam = mkLsp "gleam" ["lsp"];
    glsl_analyzer = mkLsp "glsl_analyzer" [];
    gopls = mkLsp "gopls" [];
    haskell-language-server = mkLsp "haskell-language-server" ["--lsp"];
    harper = mkLsp "harper" ["--stdio"];
    helm-ls = mkLsp "helm-ls" ["serve"];
    intelephense = mkLsp "intelephense" ["--stdio"];
    jdt-language-server = {
      cmd = lib.mkOverride overridePriority (mkLuaInline
        /*
        lua
        */
        ''
          (function()
            if type(get_jdtls_config_dir) == 'function' then
              return {
                '${bin "jdt-language-server"}',
                '-configuration',
                get_jdtls_config_dir(),
                '-data',
                get_jdtls_workspace_dir(),
                get_jdtls_jvm_args(),
              }
            end
            return { '${bin "jdt-language-server"}' }
          end)()
        '');
    };
    jq-lsp = mkLsp "jq-lsp" [];
    json = mkLsp "vscode-json-language-server" ["--stdio"];
    kotlin-language-server = mkLsp "kotlin-language-server" [];
    lua-language-server = mkLsp "lua-language-server" [];
    markdown-oxide = mkLsp "markdown-oxide" [];
    marksman = mkLsp "marksman" ["server"];
    neocmakelsp = mkLsp "neocmakelsp" ["stdio"];
    nil = mkLsp "nil" [];
    nixd = mkLsp "nixd" [];
    omnisharp = {
      cmd = lib.mkOverride overridePriority (mkLuaInline
        /*
        lua
        */
        ''
          {
            '${bin "omnisharp"}',
            '-z',
            '--hostPID',
            tostring(vim.fn.getpid()),
            'DotNet:enablePackageRestore=false',
            '--encoding',
            'utf-8',
            '--languageserver',
          }
        '');
    };
    phan = mkLsp "phan" ["-m" "json" "--no-color" "--no-progress-bar" "-x" "-u" "-S" "--language-server-on-stdin" "--allow-polyfill-parser"];
    phpactor = mkLsp "phpactor" ["language-server"];
    phpantom = mkLsp "phpantom" [];
    pyrefly = mkLsp "pyrefly" ["lsp"];
    pyright = mkLsp "pyright-langserver" ["--stdio"];
    python-lsp-server = mkLsp "pylsp" [];
    roslyn-ls = {
      cmd = lib.mkOverride overridePriority (mkLuaInline
        /*
        lua
        */
        ''
          {
            '${bin "roslyn-ls"}',
            '--logLevel',
            'Information',
            '--extensionLogDirectory',
            vim.fs.joinpath(vim.uv.os_tmpdir(), 'roslyn_ls/logs'),
            '--stdio',
          }
        '');
    };
    rumdl = mkLsp "rumdl" ["server"];
    ruby-lsp = mkLsp "ruby-lsp" [];
    ruff = mkLsp "ruff" ["server"];
    solargraph = mkLsp "solargraph" ["stdio"];
    sqls = mkLsp "sqls" [];
    superhtml = mkLsp "superhtml" ["lsp"];
    svelte-language-server = mkLsp "svelte-language-server" ["--stdio"];
    tailwindcss-language-server = mkLsp "tailwindcss-language-server" ["--stdio"];
    terraform-ls = mkLsp "terraform-ls" ["serve"];
    tinymist = mkLsp "tinymist" [];
    tofu-ls = mkLsp "tofu-ls" ["serve"];
    ty = mkLsp "ty" ["server"];
    typescript-go = mkLsp "typescript-go" ["--lsp" "--stdio"];
    typescript-language-server = mkLsp "typescript-language-server" ["--stdio"];
    vala-language-server = mkLsp "vala-language-server" [];
    vscode-css-language-server = mkLsp "vscode-css-language-server" ["--stdio"];
    vscode-json-language-server = mkLsp "vscode-json-language-server" ["--stdio"];
    wgsl-analyzer = mkLsp "wgsl-analyzer" [];
    yaml-language-server = mkLsp "yaml-language-server" ["--stdio"];
    zls = mkLsp "zls" [];
    zuban = mkLsp "zuban" ["server"];
  };

  formatters = mapAttrs (_: tool: {command = lib.mkOverride overridePriority (bin tool);}) {
    alejandra = "alejandra";
    asmfmt = "asmfmt";
    astyle = "astyle";
    biome = "biome";
    biome-check = "biome";
    biome-organize-imports = "biome";
    black = "black";
    clang-format = "clang-format";
    csharpier = "csharpier";
    denofmt = "deno";
    deno_fmt = "deno";
    fantomas = "fantomas";
    gofmt = "gofmt";
    gofumpt = "gofumpt";
    golines = "golines";
    indent = "indent";
    isort = "isort";
    jqfmt = "jqfmt";
    jsonfmt = "jsonfmt";
    mdformat = "mdformat";
    mix = "mix";
    nasmfmt = "nasmfmt";
    nixfmt = "nixfmt";
    php_cs_fixer = "php-cs-fixer";
    prettier = "prettier";
    prettierd = "prettierd";
    rubocop = "rubocop";
    ruff = "ruff";
    ruff-check = "ruff-check";
    rumdl = "rumdl";
    rustfmt = "rustfmt";
    shfmt = "shfmt";
    sqlfluff = "sqlfluff";
    sqruff = "sqruff";
    stylua = "stylua";
    superhtml = "superhtml";
    terraform-fmt = "terraform";
    tofu-fmt = "tofu";
    typstyle = "typstyle";
    yamlfmt = "yamlfmt";
    yamllint = "yamllint";
  };

  linters = mapAttrs (_: tool: {cmd = lib.mkOverride overridePriority (bin tool);}) {
    biomejs = "biome";
    deadnix = "deadnix";
    eslint_d = "eslint_d";
    golangci-lint = "golangci-lint";
    htmlhint = "htmlhint";
    ktlint = "ktlint";
    luacheck = "luacheck";
    markdownlint-cli2 = "markdownlint-cli2";
    mypy = "mypy";
    phpstan = "phpstan";
    rubocop = "rubocop";
    rumdl = "rumdl";
    selene = "selene";
    shellcheck = "shellcheck";
    sqlfluff = "sqlfluff";
    sqruff = "sqruff";
    statix = "statix";
    yamllint = "yamllint";
  };
}
