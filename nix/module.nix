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

      description = "Settings for BatmoSettings for Batmonn";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services."batmon" = {
      description = "Power Monitoring Service";
      wants = ["power-profiles-daemon.service"];
      wantedBy = ["default.target"];
      environment.PATH = mkForce "/run/wrappers/bin:${lib.makeBinPath cfg.package}";
      script = ''
        ${lib.getExe cfg.package} --config ${builtins.toJSON cfg.settings}
      '';

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        DynamicUser = true;
      };
    };
  };
}