self: {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkForce;
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
    # Create the batmon configuration file in /etc/batmon.json
    environment.etc."batmon.json".source = format.generate "batmon.json" cfg.settings;

    environment.systemPackages = [cfg.package];

    systemd.user.services.batmon = {
      description = "Simple, reactive power management service";
      documentation = ["https://github.com/NotAShelf/batmon"];
      wantedBy = ["multi-user.target"];
      environment.PATH = mkForce "/run/wrappers/bin:${lib.makeBinPath [cfg.package]}";
      script = ''
        ${lib.getExe cfg.package} --config /etc/batmon.json
      '';

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
      };
    };
  };
}
