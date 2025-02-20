{ config, lib, ... }:

let
  cfg = config.programs.kitty;
  mkOption = lib.mkOption;
in
{
  options = {
    programs.kitty.modifyFont.underlinePosition = mkOption { default = 4; };
    programs.kitty.modifyFont.strikeThroughPosition = mkOption { default = 2; };
    programs.kitty.modifyFont.cellHeight = mkOption { default = 1.5; };
  };
  config = {
    programs.kitty = {
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 16;
      };

      shellIntegration.enableFishIntegration = true;

      settings = {
        enable_audio_bell = false;

        tab_bar_margin_width = 9;
        tab_bar_margin_height = "9 0";
        tab_bar_style = "separator";
        tab_bar_min_tabs = 2;
        tab_separator = "\"\"";
        tab_title_template = "\"{fmt.fg._5c6370}{fmt.bg.default}  {fmt.fg._abb2bf}{fmt.bg._5c6370} {title.split()[0]} {fmt.fg._5c6370}{fmt.bg.default}\"";
        active_tab_title_template = "\"{fmt.fg._e5c07b}{fmt.bg.default}  {fmt.fg._282c34}{fmt.bg._e5c07b} {title.split()[0]} {fmt.fg._e5c07b}{fmt.bg.default}\"";
        tab_bar_align = "right";
        tab_bar_background = "none";
        tab_bar_edge = "bottom";

        window_padding_width = 20;
        touch_scroll_multiplier = 7.0;
      };

      extraConfig = ''
        map ctrl+shift+t new_tab_with_cwd
        map ctrl+shift+w no_op
        map ctrl+shift+f send_key ctrl+shift+f
        map ctrl+c copy_and_clear_or_interrupt
        map ctrl+v paste_from_clipboard
        sync_to_monitor no
        linux_display_server wayland

        modify_font underline_position ${toString cfg.modifyFont.underlinePosition}
        modify_font strikethrough_position ${toString cfg.modifyFont.strikeThroughPosition}
        modify_font cell_height ${toString (cfg.modifyFont.cellHeight * 100.0)}%
      '';
    };

  };
}
