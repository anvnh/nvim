# Neovim Config

<p align="center">
  <img src="images/neovim.png" alt="Neovim" width="150">
</p>

A personal Neovim configuration built with Lua and `lazy.nvim`.

## Requirements

- Neovim `>= 0.10`
- `git`
- `ripgrep`
- `fd` recommended
- A Nerd Font recommended
- Clipboard support
  - X11: `xclip` or `xsel`
  - Wayland: `wl-clipboard`
- `ImageMagick` if you use image-related workflows

This config also expects language tools to exist on `PATH` for the languages you use.

Common examples:

- Lua: `stylua`, `lua-language-server`
- Python: `ruff`, `pyright`
- C/C++: `clangd`, `clang-format`
- Nix: `nixd`
- Rust: `rust-analyzer`, `rustfmt`
- JavaScript/TypeScript: `typescript-language-server`, `prettier`
- Java: `jdtls`
- Flutter/Dart: Flutter SDK

## Install

Back up your current config first if you already use Neovim.

Linux / macOS:

```sh
git clone https://github.com/anvnh/neovim-config.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```

Windows PowerShell:

```powershell
git clone https://github.com/anvnh/neovim-config.git "$env:LOCALAPPDATA\nvim"
```

Windows `cmd.exe`:

```bat
git clone https://github.com/anvnh/neovim-config.git "%LOCALAPPDATA%\nvim"
```

## NixOS

This config works well on NixOS, but you should provide language servers, formatters, and runtime tools through your system config, Home Manager, or flakes.

Minimal example:

```nix
environment.systemPackages = with pkgs; [
  neovim
  git
  ripgrep
  fd
  wl-clipboard
  nodejs
  stylua
  lua-language-server
  nixd
  clang-tools
  rust-analyzer
  rustfmt
  ruff
  pyright
];
```

Adjust that list to match the languages you actually use.

## First Run

Start Neovim:

```sh
nvim
```

On first launch, `lazy.nvim` will install plugins automatically.

Useful commands:

- `:Lazy` to inspect plugin status
- `:Mason` to inspect external tool integration
- `:checkhealth` to inspect environment issues
- `:ConfigValidate` to run health checks from inside this config

## Notes

- Markdown autoformat is disabled by default.
- This config prefers external tools already available on `PATH`.
- Some plugins are only useful if their external dependencies are installed.

## Structure

- [init.lua](/home/anvnh/.config/nvim/init.lua): bootstrap
- [lua/options.lua](/home/anvnh/.config/nvim/lua/options.lua): core editor options
- [lua/autocmds.lua](/home/anvnh/.config/nvim/lua/autocmds.lua): autocommands
- [lua/mappings.lua](/home/anvnh/.config/nvim/lua/mappings.lua): keymap entrypoint
- [lua/custom/plugins](/home/anvnh/.config/nvim/lua/custom/plugins): plugin specs
- [lua/custom/keymaps](/home/anvnh/.config/nvim/lua/custom/keymaps): keymap modules
- [lua/custom/snippets](/home/anvnh/.config/nvim/lua/custom/snippets): snippets

## Troubleshooting

- Missing icons: install a Nerd Font and use it in your terminal.
- Clipboard not working: install the correct clipboard tool for your display server.
- LSP or formatting not working: make sure the relevant binaries exist on `PATH`.
- Plugin install errors: open `:Lazy log`.

## Validation

You can run a headless check from the repo root:

```sh
./scripts/validate.sh
```
