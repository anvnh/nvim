<h1 align="center">
  <br>
  <a href=""><img src="images/neovim.png" alt="Neovim" width="150"></a>
  <br>
	Neovim config
  <br>
</h1>

<h4 align="center">Neovim config by anvnh</h4>

<p align="center">
  • <a href="#installation"> Installation </a> •
  <a href="#post-installation"> Post installation </a> •
  <a href="#faq"> FAQ </a> •
</p>

## Installation
### Install Neovim:
Make sure neovim version is >= 0.8.0, otherwise this configuration may not work.

### Dependencies

- A clipboard helper: `xclip` or `xsel` on Linux; `win32yank` or the system clipboard on Windows
- Nerd Fonts (recommended for icon glyphs)
- go (if you develop in Go)
- imagemagick (used by some image preview utilities)
- sxiv (image viewer used by some workflows)

Windows (recommended)
- Install Neovim from https://neovim.io or via your package manager (e.g., Chocolatey or winget). See the "Platform-specific install examples" below for copyable commands.

Windows (Chocolatey example)
```powershell
# Core
choco install -y neovim git nodejs-lts ripgrep unzip zip imagemagick 7zip

# Optional / language runtimes
choco install -y openjdk # Java (for jdtls)
choco install -y golang  # Go toolchain (gopls)
# Rust: use rustup from https://rustup.rs (recommended) or install via choco if available

# Clipboard: download win32yank from its GitHub releases if you need a dedicated clipboard helper
```

Windows (winget example)
```powershell
winget install --id=Neovim.Neovim
winget install --id=Git.Git
winget install --id=OpenJS.NodeJS.LTS
winget install --id=Ripgrep.Ripgrep
winget install --id=ImageMagick.ImageMagick

# Java / JDK
winget install --id=Eclipse.Adoptium.JDK

# For Rust and some tools use the upstream installers (rustup / go install)
```

Fedora (dnf)
```sh
sudo dnf install -y git make gcc gcc-c++ unzip zip ripgrep nodejs npm ImageMagick xclip fd-find
sudo dnf groupinstall -y 'Development Tools'

# Java (for jdtls)
sudo dnf install -y java-17-openjdk-devel

# Python / Go
sudo dnf install -y python3 python3-pip golang

# Rust: install via rustup (https://rustup.rs)

# tree-sitter-cli (if you need it):
sudo npm install -g tree-sitter-cli
```

Arch / Manjaro (pacman)
```sh
sudo pacman -Syu --needed git base-devel nodejs npm unzip zip ripgrep fd imagemagick xclip tree-sitter-cli

# Java
sudo pacman -S --needed jdk-openjdk

# Optional languages
sudo pacman -S --needed python python-pip go

# Rust via rustup (recommended)
```

NixOS (nix profile or configuration.nix)
Profile example:
```sh
nix profile install nixpkgs#git nixpkgs#nodejs nixpkgs#ripgrep nixpkgs#unzip nixpkgs#gcc nixpkgs#imagemagick nixpkgs#fd nixpkgs#tree-sitter-cli nixpkgs#openjdk
```

configuration.nix example fragment:
```nix
environment.systemPackages = with pkgs; [ git nodejs ripgrep unzip gcc imagemagick fd tree-sitter-cli openjdk python3 go ];
```

For NixOS prefer managing Neovim, fonts and language toolchains via `home-manager` or flakes (see NixOS docs).

Fonts
- Nerd Fonts are strongly recommended for proper icons. Install by downloading prebuilt fonts from https://www.nerdfonts.com/ or via your distro's package manager / AUR / home-manager.

Language toolchains & formatters (common)
- Node / npm / pnpm: required for many plugin build steps and language servers. Install `prettier`, `eslint_d`, `pyright` via npm if you prefer global installs:

```sh
npm install -g prettier eslint_d pyright
```

- Rust: install via rustup (https://rustup.rs) then add rustfmt:

```sh
rustup toolchain install stable
rustup component add rustfmt
```

- Lua formatter: `stylua` (can be installed via cargo, distro package or from releases).
- Python: `python3` + `pip` (many tools expect Python on PATH). If you use `black`:

```sh
pip install --user black
```

- Java: install a JDK (Adoptium / OpenJDK) for `jdtls`.
- Go: install `go` for `gopls`.
- Dart / Flutter: install the Flutter SDK if you use the Flutter plugin.

Note about Mason and server/tool installation
- `mason.nvim` and `mason-tool-installer` automate installation for many LSPs and formatters, but they do not replace required language runtimes (for example: Java for `jdtls`, Dart/Flutter SDK for Flutter, Rust toolchain for rust tools). Install the system toolchains above for those languages.

Clipboard (Wayland vs X11)
- X11: `xclip` or `xsel`.
- Wayland: prefer `wl-clipboard` (provides `wl-copy`/`wl-paste`).

TeX / VimTeX
- If using `vimtex`, install a TeX distribution (TeX Live on Linux, MikTeX on Windows) and a PDF viewer (zathura recommended on Linux).

Optional utilities
- `fd` (faster file search used by Telescope if present).
- `sxiv` / `feh` / image viewers and `ImageMagick` for image preview workflows.

If you want, I can add a small section of one-line commands that install common formatters and linters (prettier, eslint_d, stylua, pyright, rustfmt) for each OS. Let me know which package manager you want exact commands for and I'll add them.

**Install mingw / gcc and ImageMagick using your preferred Windows package manager**

Linux

- Fedora (DNF):

```sh
sudo dnf install -y git make unzip gcc ripgrep nodejs unzip zip sxiv ImageMagick xclip
# If tree-sitter CLI is not packaged, install via npm or build from source:
sudo npm install -g tree-sitter-cli
```

- Arch / Manjaro (pacman):

```sh
sudo pacman -Syu --needed git base-devel nodejs npm unzip zip sxiv imagemagick ripgrep xclip tree-sitter-cli
```

- NixOS (using the new nix CLI / profiles)

```sh
nix profile install nixpkgs#git nixpkgs#nodejs nixpkgs#ripgrep nixpkgs#unzip nixpkgs#gcc nixpkgs#imagemagick nixpkgs#sxiv nixpkgs#tree-sitter-cli
# Fonts are best managed via home-manager or system configuration (see NixOS docs)
```

Notes for NixOS: prefer adding packages to `environment.systemPackages` in `configuration.nix` or manage Neovim and fonts via home-manager. Example (configuration.nix fragment):

```nix
environment.systemPackages = with pkgs; [ git nodejs ripgrep unzip gcc imagemagick sxiv tree-sitter-cli ];
```

> **NOTE**
> [Backup](#FAQ) your previous configuration (if any exists)

Neovim's configurations are located under the following paths, depending on your OS:

| OS | PATH |
| :------------| :----------------------------------------  |
| Linux, MacOS | `$XDG_CONFIG_HOME/nvim`, `~/.config/nvim`  |
| Windows (cmd)| `%localappdata%\nvim\`                     |
| Windows (powershell)| `$env:LOCALAPPDATA\nvim\`           |

### Install config
#### Clone this repository
> **NOTE**
> If following the recommended step above (i.e., forking the repo), replace
> `nvim-lua` with `<your_github_username>` in the commands below

<details><summary> Linux and Mac </summary>

```sh
git clone https://github.com/anvnh/neovim-config.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```

</details>

<details><summary> Windows </summary>

If you're using `cmd.exe`:

```
git clone https://github.com/anvnh/neovim-config.git "%localappdata%\nvim"
```

If you're using `powershell.exe`

```
git clone https://github.com/anvnh/neovim-config.git "${env:LOCALAPPDATA}\nvim"
```

</details>

#### Requires dependencies: 
##### Arch Linux
- Nerd fonts
- Dependencies for tree-sitter
```sh
sudo pacman -Sy nodejs npm unzip zip sxiv imagemagick
```

##### Fedora
You can install required nerd-fonts using [getnf](https://github.com/getnf/getnf)
```sh
sudo dnf install nodejs npm unzip zip sxiv ImageMagick 
```

## Post installation

Start Neovim inside any terminal emulator (e.g., `gnome-terminal`, `konsole`, `kitty`, etc.)

```sh
nvim
```

That's it! Lazy will install all the plugins you have. Use `:Lazy` to view
the current plugin status. Hit `q` to close the window.

## Quick start

- Open Neovim: `nvim` and wait for `lazy.nvim` to finish installing plugins.
- Launch the built-in plugin manager UI: `:Lazy` to check installation status.

## Troubleshooting

- Missing icons: install a Nerd Font and set your terminal to use it.
- Clipboard not working (Wayland): install `wl-clipboard` (`wl-copy`/`wl-paste`) or use a Wayland-compatible clipboard helper.
- LSP / formatters not available: confirm language toolchains are installed (Java for jdtls, Python for pylsp/black, Node for language servers, Rust via rustup, etc.)
- If something fails during plugin install, run `:Lazy log` and check for build errors; you can also run Neovim from a terminal to see stderr output.

## FAQ

* What should I do if I already have a pre-existing Neovim configuration?
  * You should back it up and then delete all associated files.
  * This includes your existing init.lua and the Neovim files in `~/.local`
    which can be deleted with `rm -rf ~/.local/share/nvim/`
* Can I keep my existing configuration in parallel to this config?
  * Yes! You can use [NVIM_APPNAME](https://neovim.io/doc/user/starting.html#%24NVIM_APPNAME)`=nvim-NAME`
    to maintain multiple configurations. For example, you can install the kickstart
    configuration in `~/.config/nvim-config1` and create an alias:
    ```
    alias nvim-kickstart='NVIM_APPNAME="nvim-config1" nvim'
    ```
    When you run Neovim using `nvim-config1` alias it will use the alternative
    config directory and the matching local directory
    `~/.local/share/nvim-config1`. You can apply this approach to any Neovim
    distribution that you would like to try out.
* What if I want to "uninstall" this configuration:
  * See [lazy.nvim uninstall](https://lazy.folke.io/usage#-uninstalling) information

## License

MIT

---
