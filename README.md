<h1 align="center">
  <br>
  <a href=""><img src="/images/neovim.png" alt="Neovim" width="150"></a>
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

### Dependencies:
External Requirements:
- Basic utils: `git`, `make`, `unzip`, C Compiler (`gcc`), tree-sister-cli for render latex (`sudo pacman -S tree-sitter-cli`)
- ripgrep
- Clipboard tool (xclip/xsel/win32yank or other depending on the platform)
- Nerd fonts
- - Language Setup:
  - If you want to write Typescript, you need `npm`
  - If you want to write Golang, you will need `go`
  - etc...


> **NOTE**
> [Backup](#FAQ) your previous configuration (if any exists)

Neovim's configurations are located under the following paths, depending on your OS:

| OS | PATH |
| :------------| :---------------------------------------- |
| Linux, MacOS | `$XDG_CONFIG_HOME/nvim`, `~/.config/nvim` |
| Windows (cmd)| `%localappdata%\nvim\` |
| Windows (powershell)| `$env:LOCALAPPDATA\nvim\` |

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
