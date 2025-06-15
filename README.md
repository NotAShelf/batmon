# 🔋 Batmon

[Watt]: https://github.com/notashelf/watt

> [!WARNING]
> Batmon has been deprecated, and the repository has been abandoned completely.
> I find the current approach to be inefficient (and insufficient) so no further
> work will be put into Batmon. However, I have began working on a much more
> powerful alternative to Batmon, called [Watt]. If you have at any point in
> time wanted a better alternative to TLP or auto-cpufreq, Watt is the answer.
> This repo has been archived, and further development will continue as a part
> of Watt if necessary.

Dead-simple, somewhat configurable battery monitor for Linux. Batmon monitors
the battery path in real time and adjusts your power profiles accordingly to
optimize battery life for e.g. laptops.

## Features

- Real-time monitoring of battery status
- Dynamic adjustment of power profiles
- Simple configuration though JSON configuration file
  - Optional command execution on state changes

## Installation

### Prerequisites

- Upower
- powerprofilesctl
- Nix or Go

### Nix

You are strongly encouraged to get Batmon through Nix, using the flake located
in this repository. You may install it manually on non-NixOS systems using
`nix profile install`.

```bash
nix profile install github:NotAShelf/batmon
```

Or on NixOS systems using the package exposed for your system.

```nix
{inputs, pkgs, ...}: {
  environment.systemPackages = [
    inputs.batmon.packages.${pkgs.stdenv.system}.default
  ];
}
```

Alternatively, using the NixOS _module_ to install Batmon and configure a
systemd service for you.

```nix
{inputs, pkgs, ...}: {
  imports = [inputs.batmon.nixosModules.default];
  services.batmon.enable = true;
}
```

### Manually

```console
go install . # this will install Batmon in your $GOPATH
```

Start Batmon through your terminal, or as a systemd service.

## Configuration

By default, Batmon will load the configuration from `config.json` located in the
current directory. You can specify a different configuration file using the
`--config` flag:

```console
batmon -c /path/to/config.json
```

The configuration file should contain a list of batteries to monitor, along with
any custom commands or extra commands to execute. Here's an example of a
configuration file:

```json
{
  "batPaths": [
    {
      "path": "/sys/class/power_supply/BAT0",
      "command": "powerprofilesctl set performance",
      "extraCommand": "echo 'Battery is charging' | wall"
    }
  ]
}
```

- You can leave `command` empty to use the default behaviour - which will switch
  active powerprofile using `powerprofiles set performance | balanced`

- `extraCommand`, if provided, will be executed in addition to the `command`
  value.
