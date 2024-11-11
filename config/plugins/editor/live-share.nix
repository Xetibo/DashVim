{ pkgs, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "live-share";
      src = pkgs.fetchFromGitHub {
        owner = "azratul";
        repo = "live-share.nvim";
        rev = "bf5e8e087c368aae0325a09d1ea43f2a08f5e9aa";
        hash = "sha256-fUYFdeP+T+KwGpvm0eh5GcAS35ZU5f0N9A/JsqBgHGA=";
      };
    })
  ];
  extraConfigLua = # lua
    ''
      require("live-share").setup({
        port_internal = 8765,
        max_attempts = 40, -- 10 seconds
        service = "serveo.net"
      })
    '';
}
