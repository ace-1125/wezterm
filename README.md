# WezTerm configs

Small source-of-truth repo for my WezTerm configs across machines.

## Files

- `windows.lua` — known-good Windows config
- `linux.lua` — future Linux config, if/when the Linux setup deserves its own file

The repo intentionally keeps complete OS-specific configs rather than forcing everything through one abstraction layer. The files are small, and the machines have meaningfully different
needs.

## Current Windows config

`windows.lua` is tuned for Windows clients that are often used as:

```text
WezTerm -> SSH -> tmux -> nvim
```

Notable behavior:

- PowerShell is the default local shell
- terminal title/tab titles strip trailing `.exe`
- tab bar stays mostly hidden, but can be toggled with `Alt+Shift+B`
- tabs can be renamed with `Alt+Shift+N`
- battery status appears while discharging
- `Alt+Shift+Space` opens QuickSelect
- CSI-u key encoding is enabled so modified keys such as `Ctrl+1..9` survive the trip to tmux/Neovim

### Machine-local settings

The small `machine` table near the top of `windows.lua` is the intended place for per-client edits:

```lua
local machine = {
  background_image = wezterm.home_dir .. "/Pictures/Backgrounds/terminal-background-d20.png",
  default_shell = { "powershell.exe", "-NoLogo" },
}
```

`wezterm.home_dir` keeps paths rooted at the current user's home directory, so the config does not need a hard-coded `C:/Users/<name>` prefix. In practice, most Windows machines should only need the relative background path adjusted if their local file layout differs.

## Install

### Windows

Copy `windows.lua` to:

```text
%USERPROFILE%\.wezterm.lua
```

Before or after copying, review the `machine` table at the top of the file for any client-specific edits.

### Linux

When a Linux config exists, copy or symlink it to:

```text
~/.wezterm.lua
```

## Philosophy

- `Super` / `Win` is for the OS
- `Alt` is for terminal-layer actions
- `Ctrl` is for applications running inside the terminal

The goal is a small config that keeps those layers distinct rather than a maximal WezTerm showcase.
