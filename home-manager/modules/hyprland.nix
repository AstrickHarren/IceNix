{
  lib,
  pkgs,
  config,
  ...
}:

let
  bind_switch_workspace = builtins.concatLists (
    builtins.genList (
      i:
      let
        x = builtins.toString (i + 1);
      in
      [
        "$mod, ${x}, workspace, ${x}"
        "$mod SHIFT, ${x}, movetoworkspace, ${x}"
      ]
    ) 9
  );
in
{
  options.icenix = {
    keyboards.capsAsEsc = lib.mkEnableOption "mapping capslock to escape";
    keyboards.layouts = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      example = {
        us = {
          enable = true;
          layouts = "qwerty";
          usedForBindings = true;
        };
        il.enable = true;
      };
    };
  };

  config = {
    home.packages = with pkgs; [
      playerctl
      killall
    ];
    services.playerctld.enable = true;

    xdg.configFile = {
      "bin/toggle_fuzzel" = {
        text = ''
          #!/bin/sh
          if pgrep -x fuzzel; then
              killall fuzzel
          else
              fuzzel
          fi
        '';
        executable = true;
      };
    };

    home.sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
      SDL_VIDEODRIVER = "wayland";
      XDG_SESSION_TYPE = "wayland";
    };

    # Enable screensharing
    xdg.portal = {
      enable = true;
      extraPortals = [
        # using wlr for now as xdg-desktop-portal-hyprland doesn't work well
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
      configPackages = [ pkgs.hyprland ];
    };

    ## Using wlr for now (see comment above)
    # home.file."${config.xdg.configHome}/hypr/xdph.conf" = {
    #   text = ''
    #     screencopy {
    #       allow_token_by_default = true
    #     }
    #   '';
    # };

    wayland.windowManager.hyprland = {
      package = pkgs.hyprland;
    };

    wayland.windowManager.hyprland.settings = {
      "$mod" = "SUPER";
      decoration = {
        rounding = 10;
      };

      input =
        let
          layouts = config.icenix.keyboards.layouts;
          capsAsEsc = config.icenix.keyboards.capsAsEsc;

          kb_layout =
            let
              intoList = lib.mapAttrsToList (
                k: v: {
                  name = k;
                  enable = v.enable;
                  usedForBindings = v.usedForBindings or false;
                }
              );
              filter = lib.filter (x: x.enable);
              concat = lib.fold (x: acc: if x.usedForBindings then x.name + acc else acc + "," + x.name) "";
            in
            concat (
              filter (
                intoList (
                  layouts
                  // {
                    us.enable = true;
                    us.usedForBindings = true;
                  }
                )
              )
            ); # Enable `us` by default
        in
        {
          inherit kb_layout;
          kb_options = lib.mkMerge [
            (lib.mkIf capsAsEsc "caps:escape, grp:alt_shift_toggle")
            (lib.mkIf (!capsAsEsc) "grp:alt_shift_toggle")
          ];
          touchpad = {
            natural_scroll = true;
            scroll_factor = 0.2;
          };
          numlock_by_default = true;
        };

      cursor = {
        # This fixes firefox not changing cursor (See #1)
        no_hardware_cursors = true;
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_min_fingers = true;
        workspace_swipe_distance = 500;
        workspace_swipe_min_speed_to_force = 10;
      };

      binds = {
        allow_workspace_cycles = true;
      };
      bind = [
        # IMPORTANT: use `wev` to determine the keycode names
        "$mod, Slash, exec, xdg-open https://duckduckgo.com"
        "$mod, Return, exec, kitty"
        "$mod, Space, exec, ${config.xdg.configHome}/bin/toggle_fuzzel"
        "$mod, M, exec, spotify --enable-features=UseOzonePlatform --ozone-platform=wayland"
        "$mod, Q, killactive"
        "$mod CTRL, Q, exec, hyprlock"

        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"

        "$mod, Left, movefocus, l"
        "$mod, Down, movefocus, d"
        "$mod, Up, movefocus, u"
        "$mod, Right, movefocus, r"

        "$mod, mouse_down, workspace, -1"
        "$mod, mouse_up, workspace, +1"

        "$mod CTRL, H, workspace, -1"
        "$mod CTRL, L, workspace, +1"
        "$mod SHIFT CTRL, H, movetoworkspace, -1"
        "$mod SHIFT CTRL, L, movetoworkspace, +1"

        "$mod CTRL, Left, workspace, -1"
        "$mod CTRL, Right, workspace, +1"
        "$mod SHIFT CTRL, Left, movetoworkspace, -1"
        "$mod SHIFT CTRL, Right, movetoworkspace, +1"

        "$mod, Tab, workspace, previous"
      ] ++ bind_switch_workspace;
      bindl = [
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"
      ];
      binde = [
        "$mod, Equal, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        "$mod, Minus, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      misc = {
        focus_on_activate = true;
      };
    };
  };
}
