# 🔋 Batmon

> **Batmon** is a dead-simple battery monitor for Linux written in Go. It
> provides real-time monitoring of battery status and adjusts the power profile
> accordingly to optimize battery life.

## Features

- Real-time monitoring of battery status
- Adjustment of power profile based on battery status
- Support for custom commands and extra commands
- Configuration via a JSON file
- Not written in Rust (the codebase is _readable_)

## Installation

## Prerequisites

- Upower
- powerprofilesctl
- Nix or Go

### Nix

**Batmon** is primarily distributed through a Nix flake. You may install it
manually using `nix profile install github:NotAShelf/batmon`

### Manually

```console
go install . # this will install Batmon in your $GOPATH
```

## Usage

To start using Batmon, use the following command:

```
batmon
```

By default, Gomon will load the configuration from config.json in the current
directory. You can specify a different configuration file using the `--config`
flag:

```console
batmon -c /path/to/config.json
```

The configuration file should contain a list of batteries to monitor, along
with any custom commands or extra commands to execute. Here's an example of
a configuration file:

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

- You can leave `command` empty to use the default behaviour - which will
  switch active powerprofile using `powerprofiles set performance | balanced`

- `extraCommand`, if provided, will be executed in addition to the `command`
  value.
