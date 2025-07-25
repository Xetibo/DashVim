{pkgs, ...}: {
  extraPlugins = [
    pkgs.vimPlugins.live-share-nvim
  ];
  extraConfigLua =
    # lua
    ''
      require("live-share").setup({
        port_internal = 8765,
        max_attempts = 40, -- 10 seconds
        service = "serveo.net"
      })
    '';
}
