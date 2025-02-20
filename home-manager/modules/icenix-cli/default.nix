{ config, ... }:
{
  home.shellAliases = {
    icenix = "${config.xdg.configHome}/bin/icenix";
  };
  xdg.configFile."bin/icenix" = {
    source = ./icenix;
  };
}
