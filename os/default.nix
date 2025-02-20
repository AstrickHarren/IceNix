{
  inputs,
  settings,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ settings.hardware ];

  options.icenix = {
    nvidia.enable = lib.mkEnableOption "Enable Nvidia Driver";
    dockerRootless.enable = lib.mkEnableOption "Enable rootless Docker";
  };

  config =
    let
      docker = lib.mkIf config.icenix.dockerRootless.enable {
        virtualisation.docker.rootless = {
          enable = true;
          setSocketVariable = true;
          daemon.settings = {
            data-root = "/home/${settings.userName}/.cache/docker";
          };
        };
      };
      nvidia = lib.mkIf config.icenix.nvidia.enable {
        nixpkgs.config.nvidia.acceptLicense = true;
        hardware.nvidia = lib.mkIf config.icenix.nvidia.enable {
          open = false;
          modesetting.enable = true;
          nvidiaSettings = true;
        };
        services.xserver.videoDrivers = [ "nvidia" ];
      };
      module = {
        nixpkgs.config.allowUnfree = true;
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        boot = settings.boot;

        fonts.packages = with pkgs; [
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-emoji
          nerd-fonts.fira-code
          nerd-fonts.fantasque-sans-mono
          nerd-fonts.sauce-code-pro
          nerd-fonts.jetbrains-mono
          inputs.apple-fonts.packages.${settings.system}.sf-pro
        ];

        networking.hostName = settings.hostName;
        networking.networkmanager.enable = true;

        time.timeZone = "US/Central";

        hardware.graphics.enable = true;
        hardware.bluetooth.enable = true;
        hardware.bluetooth.powerOnBoot = true;

        services.pipewire = {
          enable = true;
          pulse.enable = true;
        };

        services.greetd = {
          enable = true;
          vt = 3;
          settings = {
            initial_session = {
              user = settings.userName;
              command = "Hyprland";
            };
            default_session = {
              user = settings.userName;
              command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a * %h | %F' --cmd Hyprland";
            };
          };
        };

        services.upower.enable = true;

        users.users.${settings.userName} = {
          isNormalUser = true;
          extraGroups = [
            "wheel"
            "networkmanager"
            "dialout"
          ];
        };

        # Enable gtk4 apps
        programs.dconf.enable = true;

        environment.systemPackages = with pkgs; [
          home-manager
        ];
        system.stateVersion = settings.stateVersion;
      };
    in
    lib.mkMerge [
      docker
      nvidia
      module
    ];
}
