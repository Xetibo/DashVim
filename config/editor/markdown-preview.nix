{
  config',
  pkgs,
  mkDashDefault,
  lib,
  ...
}: let
  cfg = config'.markdownPreview;

  # Upstream serves previews through a pkg-bundled node binary fetched by
  # app/install.sh from GitHub releases (tag v<root package.json version>).
  # The Nix store is read-only so the plugin could never self-install it;
  # provision the binary into app/bin at build time instead. The binary is
  # opaque to patching: patchelf corrupts it (rewritten headers shift pkg's
  # embedded payload offsets), and an explicit-loader wrapper breaks it too
  # (pkg locates its snapshot via /proc/self/exe, which then points at the
  # loader: "Pkg: Error reading from file"). So the pristine binary runs
  # inside a buildFHSEnv bubble, where /lib64/ld-linux exists and the
  # binary keeps its own exe identity.
  serverBin = pkgs.fetchurl {
    url = "https://github.com/iamcco/markdown-preview.nvim/releases/download/v0.0.10/markdown-preview-linux.tar.gz";
    hash = "sha256-letNJ3TGLpOZjEE2H+InalE07xc93aspAm0074CtRO8=";
  };

  pluginSrc = pkgs.fetchFromGitHub {
    owner = "iamcco";
    repo = "markdown-preview.nvim";
    rev = "a923f5fc5ba36a3b17e289dc35dc17f66d0548ee";
    hash = "sha256-TBXdG/Ih5DusAYZJyn37zVqHcMD85VkjrCoLyTo/KBg=";
  };

  # Store path deliberately mirrors the upstream layout
  # (<name>/app/bin/markdown-preview-linux): app/index.js chdirs into
  # process.execPath with /(markdown-preview.nvim.*?app).+?$/ stripped, so
  # the binary must live under a markdown-preview.nvim.../app/... path or
  # the replace misses and it chdirs into the binary file itself (ENOTDIR).
  # The extract carries the full app tree (out/, _static, pages, server.js)
  # because the server resolves assets like out/404.html relative to cwd.
  serverExtract = pkgs.stdenv.mkDerivation {
    pname = "markdown-preview.nvim";
    version = "0.0.10";
    src = pluginSrc;
    # The pkg payload offsets are baked into the binary; strip or ELF
    # rewriting of any kind corrupts it.
    dontStrip = true;
    dontPatchELF = true;
    installPhase = ''
      mkdir -p $out/app/bin
      cp -r app/out app/_static app/pages app/server.js app/package.json $out/app/
      tar xzf ${serverBin} -C $out/app/bin
    '';
  };

  serverFhs = pkgs.buildFHSEnv {
    name = "markdown-preview-linux";
    targetPkgs = ps: with ps; [glibc stdenv.cc.cc.lib zlib];
    runScript = "${serverExtract}/app/bin/markdown-preview-linux";
  };

  markdownPreview = pkgs.vimUtils.buildVimPlugin {
    pname = "markdown-preview.nvim";
    version = "0.0.10";
    src = pluginSrc;
    # Plugin-visible path stays app/bin/markdown-preview-linux, which the
    # plugin's rpc contract requires.
    postInstall = ''
      mkdir -p $out/app/bin
      cp ${serverFhs}/bin/markdown-preview-linux $out/app/bin/markdown-preview-linux
      chmod +x $out/app/bin/markdown-preview-linux
    '';
  };

  flag = b:
    if b
    then 1
    else 0;
in
  lib.mkIf cfg.enable {
    vim = {
      # Vimscript plugin: no setupModule. lz.n loads it on its commands or
      # for markdown buffers; the node server only starts on toggle.
      lazy.plugins."markdown-preview.nvim" = mkDashDefault {
        package = markdownPreview;
        cmd = ["MarkdownPreview" "MarkdownPreviewStop" "MarkdownPreviewToggle"];
        ft = ["markdown"];
      };

      globals =
        lib.attrsets.mapAttrs (_: mkDashDefault) {
          mkdp_port = cfg.port;
          mkdp_theme = cfg.theme;
          mkdp_browser = cfg.browser;
          mkdp_auto_start = flag cfg.autoStart;
          mkdp_auto_close = flag cfg.autoClose;
          mkdp_combine_preview = flag cfg.combinePreview;
          mkdp_filetypes = cfg.filetypes;
        }
        // cfg.extraConfig;

      keymaps = lib.mkIf config'.useDefaultKeybinds [
        {
          mode = "n";
          key = "<leader>mm";
          action = "<CMD>MarkdownPreviewToggle<CR>";
          noremap = true;
          silent = true;
          desc = "Toggle markdown preview";
        }
      ];
    };
  }
