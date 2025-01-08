self: {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkForce mkDefault;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib) types;

  format = pkgs.formats.json {};
  cfg = config.services.batmon;
in {
  options.services.batmon = {
    enable = mkEnableOption "batmon for real-time battery monitoring";

    package = mkOption {
      description = "The batmon package to use";
      type = types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.batmon;
    };

    settings = mkOption {
      type = format.type;
      default = {};
      example = {
        batPaths = [
          {
            path = "/sys/class/power_supply/BAT0";
            extraCommand = "notify-send 'State changed!'";
          }
        ];
      };

      description = "Settings for Batmon";
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [cfg.package];

      # Create the batmon configuration file in /etc/batmon.json
      etc."batmon.json".source = format.generate "batmon.json" cfg.settings;
    };

    # Batmon depends on power-profiles daemon
    services.power-profiles-daemon.enable = mkDefault true;

    systemd.user.services.batmon = {
      description = "Simple, reactive power management service";
      documentation = ["https://github.com/NotAShelf/batmon"];
      wantedBy = ["multi-user.target"];
      environment.PATH = mkForce "/run/wrappers/bin:${lib.makeBinPath [
        # Batmon expects powerprofilesctl in PATH
        config.services.power-profiles-daemon.package
      ]}";

      script = ''
        ${lib.getExe cfg.package} --config /etc/batmon.json
      '';

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
      };
    };

    assertions = [
      {
        assertion = config.services.power-profiles-daemon.enable;
        message = "Batmon requies 'services.power-profiles-daemon.enable' to be true!";
      }
    ];
  };
}
