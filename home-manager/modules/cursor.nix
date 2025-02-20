{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    icenix.cursor.theme = lib.mkOption { default = "Bibata-Modern-Ice"; };
    icenix.cursor.size = lib.mkOption { default = 24; };
  };

  config = {
    gtk = {
      enable = true;
      # theme = {
      #   package = pkgs.flat-remix-gtk;
      #   name = "Flat-Remix-GTK-Grey-Darkest";
      # };
      #
      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };
      #
      # font = {
      #   name = "Sans";
      #   size = 11;
      # };
    };

    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = config.icenix.cursor.theme;
      size = config.icenix.cursor.size;
    };

    wayland.windowManager.hyprland.settings = {
      env = [
        "XCURSOR_THEME,${config.icenix.cursor.theme}"
        "XCURSOR_SIZE,${toString config.icenix.cursor.size}"
      ];
    };
  };
}
