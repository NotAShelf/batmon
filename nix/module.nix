{
  self,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkForce types;
  inherit (lib.options) mkOption mkEnableOption;

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
      description = "Settings for Batmon";
      type = types.attrs;
      default = {};
      example = lib.literalExpression ''
        {
          batPaths = [
            {
              path = "/sys/class/power_supply/BAT0";
              extraCommand = "notify-send 'State changed!'";
            }
          ];
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services."batmon" = {
      description = "Power Monitoring Service";
      environment.PATH = mkForce "/run/wrappers/bin:${lib.makeBinPath cfg.package}";
      script = ''
        ${lib.getExe cfg.package} --config ${builtins.toJSON cfg.settings}
      '';

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
      };

      wants = ["power-profiles-daemon.service"];
      wantedBy = ["default.target"];
    };
  };
}
