# macOS Setup Guide — `fearful`
> Maximiliano Falicoff · Migrated from nix-darwin → Homebrew + chezmoi · April 2026

This guide replaces the previous nix-darwin setup. Everything is now managed with **Homebrew** (packages) and **chezmoi** (dotfiles). The structure mirrors what nix-darwin was doing, but without Nix.

---

## Table of Contents

1. [Overview of the New Stack](#1-overview-of-the-new-stack)
2. [Bootstrap: From Zero to Running](#2-bootstrap-from-zero-to-running)
3. [Homebrew & Packages](#3-homebrew--packages)
4. [Shell Setup (Zsh + Oh My Zsh)](#4-shell-setup-zsh--oh-my-zsh)
5. [tmux Setup](#5-tmux-setup)
6. [Git Configuration](#6-git-configuration)
7. [SSH & 1Password Agent](#7-ssh--1password-agent)
8. [chezmoi — Dotfiles Management](#8-chezmoi--dotfiles-management)
9. [Fonts](#9-fonts)
10. [macOS System Preferences](#10-macos-system-preferences)
11. [Manual App Config](#11-manual-app-config)
12. [Day-to-Day: Keeping Things Updated](#12-day-to-day-keeping-things-updated)
13. [Quick-Start Checklist](#13-quick-start-checklist)

---

## 1. Overview of the New Stack

| What | Tool | Previously |
|---|---|---|
| Package management | **Homebrew** + `Brewfile` | nix-darwin homebrew module |
| CLI tools | **Homebrew** formulae | Nix packages (home-manager) |
| Dotfiles | **chezmoi** | home-manager |
| macOS settings | **shell script** (`macos-defaults.sh`) | nix-darwin system.defaults |
| Shell config | **`~/.zshrc`** managed by chezmoi | home-manager programs.zsh |
| Git config | **`~/.gitconfig`** managed by chezmoi | home-manager programs.git |
| Secrets | **1Password CLI** + `op` injection | SOPS + sops-nix |

---

## 2. Bootstrap: From Zero to Running

### Step 1 — macOS prerequisites

Apply all macOS updates:
```
System Settings → General → Software Update
```

Install Xcode Command Line Tools:
```bash
xcode-select --install
```

Install Rosetta 2 (Apple Silicon):
```bash
softwareupdate --install-rosetta --agree-to-license
```

### Step 2 — Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After install, add Homebrew to PATH. On Apple Silicon, add this to `~/.zprofile`:
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Step 3 — Install chezmoi and restore dotfiles

```bash
brew install chezmoi

# Initialize from your dotfiles repo (update URL to your actual remote)
chezmoi init --apply git@github.com:mazilious/dotfiles.git
```

This will pull your dotfiles repo and apply all managed files to `~`.

### Step 4 — Install all packages via Brewfile

```bash
brew bundle --file=~/.local/share/chezmoi/Brewfile
```

> The `Brewfile` is included in this repo (see section 3). It installs all formulae, casks, and App Store apps in one command.

### Step 5 — Apply macOS system preferences

```bash
bash ~/.local/share/chezmoi/macos-defaults.sh
```

Then log out and back in (or restart) for all settings to take effect.

### Step 6 — Set up Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

> After this runs, your `~/.zshrc` from chezmoi may be overwritten by the Oh My Zsh installer. Run `chezmoi apply` again to restore it:
```bash
chezmoi apply
```

---

## 3. Homebrew & Packages

All packages are tracked in a `Brewfile` (see `Brewfile` artifact alongside this guide). Install everything at once with:

```bash
brew bundle --file=~/path/to/Brewfile
```

### Formulae — Language Runtimes

| Formula | Purpose |
|---|---|
| `bun` | Fast JS runtime & package manager (via `oven-sh/bun` tap) |
| `dotnet-sdk` | .NET (via cask) |

### Formulae — Infrastructure & Cloud

| Formula | Purpose |
|---|---|
| `terraform` | HashiCorp IaC |
| `azure-cli` | Azure cloud CLI |

### Formulae — Dev Tools

| Formula | Purpose |
|---|---|
| `git-delta` | Beautiful diff viewer (side-by-side) |
| `git-lfs` | Git Large File Storage |
| `git-filter-repo` | Fast git history rewriting |
| `lazygit` | TUI Git client |
| `lazydocker` | Docker TUI |
| `just` | Command runner (Makefile alternative) |
| `jq` | JSON processor |
| `direnv` | Per-directory env variables |
| `age` | Modern file encryption |
| `sops` | Secrets file manager |
| `opencode` | AI coding agent for the terminal |
| `chezmoi` | Dotfiles manager |
| `mas` | Mac App Store CLI |

### Formulae — Shell & Terminal

| Formula | Purpose |
|---|---|
| `fzf` | Fuzzy finder |
| `ripgrep` | Ultra-fast grep (`rg`) |
| `eza` | Modern `ls` with icons & git status |
| `yazi` | TUI file manager |
| `btop` | Resource monitor |
| `neofetch` | System info |
| `tmux` | Terminal multiplexer |
| `pure` | Zsh prompt (via npm — see shell setup) |

### Casks — GUI Apps

**Security**
`yubico-authenticator`

**Browsers**
`firefox`, `google-chrome`, `zen`

**Productivity**
`raycast`

**Development**
`ghostty`, `zed`, `visual-studio-code`, `jetbrains-toolbox`, `orbstack`, `gitkraken`, `mongodb-compass`, `bruno`, `claude-code`

**Communication & Media**
`discord`, `proton-mail`, `spotify`

**Cloud & Sync**
`insync`

**System Utilities**
`wallspace`

### App Store Apps (via `mas`)

| App | ID |
|---|---|
| Amphetamine | 937984704 |
| AutoMounter | 1160435653 |
| Tailscale | 1475387142 |
| Infuse | 1136220934 |

---

## 4. Shell Setup (Zsh + Oh My Zsh)

### Install Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Install Zsh plugins

These plugins aren't bundled with Oh My Zsh and must be cloned manually:

```bash
# Autosuggestions (fish-like suggestions)
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Syntax highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Autocomplete
git clone https://github.com/marlonrichert/zsh-autocomplete \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete
```

### Install Pure prompt

```bash
npm install --global pure-prompt
```

### Your `~/.zshrc`

This is the equivalent of what your `shell.nix` was generating. Manage it via chezmoi:

```zsh
# Path — Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
plugins=(git azure bun docker fzf zsh-autosuggestions zsh-syntax-highlighting zsh-autocomplete)
source $ZSH/oh-my-zsh.sh

# Pure prompt
autoload -U promptinit; promptinit
prompt pure

# Editor
export EDITOR="nvim"
export XDG_PICTURES_DIR="~/screenshots"

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.local/share/zsh/history"

# direnv
eval "$(direnv hook zsh)"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Aliases
alias k="kubectl"
alias ll="ls -l"
alias ndev="nix develop --command zsh"   # keep if you use nix shells occasionally
alias ls="eza --icons=auto"

# eza
# (eza integrates automatically when aliased)

# tmux: auto-attach or create session
if [[ -z "$TMUX" ]]; then
  tmux attach 2>/dev/null || tmux
fi
```

---

## 5. tmux Setup

### Install TPM (Tmux Plugin Manager)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### Your `~/.tmux.conf`

```
# Base index from 1
set -g base-index 1
setw -g pane-base-index 1

# Mouse support
set -g mouse on

# 256 colors
set -g default-terminal "screen-256color"

# Plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'arcticicestudio/nord-tmux'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'xamut/tmux-weather'

# Initialize TPM (keep at bottom)
run '~/.tmux/plugins/tpm/tpm'
```

After starting tmux, press `Ctrl+b` then `I` (capital i) to install all plugins.

---

## 6. Git Configuration

Replaces what `git.nix` was generating. Manage `~/.gitconfig` via chezmoi.

```bash
git config --global user.name "Maximiliano Falicoff"
git config --global user.email "git@mazilious.org"
git config --global init.defaultBranch main
git config --global push.autoSetupRemote true
git config --global pull.rebase true
git config --global core.pager "delta"

# Delta (diff viewer)
git config --global delta.features "side-by-side"

# Git LFS
git lfs install

# Aliases
git config --global alias.br branch
git config --global alias.co checkout
git config --global alias.st status
git config --global alias.cm "commit -m"
git config --global alias.ca "commit -am"
git config --global alias.dc "diff --cached"
git config --global alias.amend "commit --amend -m"
git config --global alias.update "submodule update --init --recursive"
git config --global alias.foreach "submodule foreach"
git config --global alias.ls "log --pretty=format:'%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]' --decorate"
git config --global alias.ll "log --pretty=format:'%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]' --decorate --numstat"
```

### Commit signing via 1Password SSH agent

```bash
git config --global gpg.format ssh
git config --global user.signingkey "~/.ssh/id_ed25519.pub"
git config --global commit.gpgsign true
git config --global gpg.ssh.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
```

---

## 7. SSH & 1Password Agent

Your SSH keys live in **1Password** — never on disk as private keys.

### Steps

1. Install 1Password (via Brewfile) and sign in
2. Enable SSH agent: `1Password → Settings → Developer → Use the SSH Agent ✓`
3. Enable CLI: `1Password → Settings → Developer → Integrate with 1Password CLI ✓`
4. Create `~/.ssh/config`:

```
Host *
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

5. Export your public keys from 1Password and place them at:
   - `~/.ssh/id_ed25519.pub`
   - `~/.ssh/id_rsa.pub`

6. Sign into the 1Password CLI:
```bash
op signin
```

---

## 8. chezmoi — Dotfiles Management

chezmoi is the replacement for home-manager's dotfile management.

### How it works

chezmoi keeps a **source directory** (usually `~/.local/share/chezmoi`) that mirrors `~`, with files prefixed according to their type. You edit files in the source, then apply them.

### Initial setup (new machine)

```bash
chezmoi init --apply git@github.com:mazilious/dotfiles.git
```

### Files to manage in chezmoi

Add these to your chezmoi source so they're tracked and reproducible:

| File | Purpose |
|---|---|
| `~/.zshrc` | Zsh config |
| `~/.zprofile` | Login shell env (PATH, etc.) |
| `~/.gitconfig` | Git configuration |
| `~/.ssh/config` | SSH client config |
| `~/.tmux.conf` | tmux config |
| `~/.config/ghostty/config` | Ghostty terminal config |
| `~/.terraformrc` | Terraform CLI config |
| `Brewfile` | Package list (store at root of chezmoi repo) |
| `macos-defaults.sh` | macOS preferences script |

### Adding files to chezmoi

```bash
chezmoi add ~/.zshrc
chezmoi add ~/.gitconfig
chezmoi add ~/.ssh/config
chezmoi add ~/.tmux.conf
chezmoi add ~/.config/ghostty/config
chezmoi add ~/.terraformrc
```

### Edit a managed file

```bash
chezmoi edit ~/.zshrc     # opens in $EDITOR
chezmoi apply             # applies changes to ~
```

### Sync to/from repo

```bash
# Push changes
chezmoi cd                # go to source dir
git add -A && git commit -m "update dotfiles" && git push

# Pull changes on another machine
chezmoi update
```

### Recommended chezmoi repo structure

```
dotfiles/
├── Brewfile                    ← brew bundle file
├── macos-defaults.sh           ← macOS preferences script
├── dot_zshrc                   ← → ~/.zshrc
├── dot_zprofile                ← → ~/.zprofile
├── dot_gitconfig               ← → ~/.gitconfig
├── dot_tmux.conf               ← → ~/.tmux.conf
├── dot_terraformrc             ← → ~/.terraformrc
├── dot_ssh/
│   └── config                  ← → ~/.ssh/config
├── dot_config/
│   └── ghostty/
│       └── config              ← → ~/.config/ghostty/config
└── nixos/                      ← keep your NixOS configs for other hosts!
```

> **Tip:** Keep the `nixos/` folder in the same repo for your Linux machines. chezmoi only manages the files you explicitly add — it ignores the rest.

---

## 9. Fonts

Your Nix config used JetBrains Mono Nerd Font (primary), Fira Code Nerd Font, Droid Sans Mono, and Hack. Install them via Homebrew:

```bash
brew tap homebrew/cask-fonts

brew install --cask \
  font-jetbrains-mono-nerd-font \
  font-fira-code-nerd-font \
  font-droid-sans-mono-nerd-font \
  font-hack-nerd-font
```

Set **JetBrainsMono Nerd Font Mono** as your terminal font in Ghostty config.

---

## 10. macOS System Preferences

These settings are all applied by `macos-defaults.sh` (see artifact). They match exactly what nix-darwin was setting in `system.nix`. Run it once after a fresh install:

```bash
bash macos-defaults.sh
```

Then log out and back in.

### What the script sets

**Dock**
- Auto-hide: on
- Show recent apps: off

**Finder**
- Full path in title bar
- All file extensions visible
- No extension change warning
- Path bar + status bar shown
- Folders sorted first
- Search in current folder by default
- External drives, hard drives, mounted servers shown on desktop

**Trackpad**
- Tap to click: on
- Two-finger right click: on

**Keyboard**
- CapsLock → Escape
- Key repeat delay: 15 (fast)
- Key repeat rate: 3 (fast)

**Appearance**
- Dark mode
- Natural scrolling: on
- Autocorrect / autocapitalize / auto-substitutions: all off
- Expanded save panels by default

**Security**
- Screen saver password: immediate
- Guest user: off
- Personalized Apple Ads: off
- Photos auto-open on device connect: off

**Window Manager**
- Separate spaces per display
- Stage Manager: desktop icons and widgets visible
- Click wallpaper to reveal desktop: off

**Misc**
- No `.DS_Store` on network or USB volumes
- Screenshots to `~/Desktop` as PNG
- Hostname: `fearful`
- TouchID for sudo: on (set separately — see below)

### TouchID for sudo

```bash
sudo nano /etc/pam.d/sudo_local
```

Add this line at the top:
```
auth       sufficient     pam_tid.so
```

---

## 11. Manual App Config

These apps need manual configuration that can't be scripted.

### Raycast
Set as Spotlight replacement:
1. Disable Spotlight: `System Settings → Keyboard → Shortcuts → Spotlight → uncheck ⌘ Space`
2. Set Raycast hotkey to `⌘ Space` in Raycast preferences

### 1Password
- Sign in and set up SSH agent (see section 7)
- Enable browser extensions in Firefox/Chrome

### JetBrains Toolbox
Install whichever IDEs you need (GoLand, IntelliJ, etc.) from Toolbox.

### Ghostty
Config lives at `~/.config/ghostty/config`. Managed by chezmoi. Key settings to include:
```
font-family = JetBrainsMono Nerd Font Mono
font-size = 13
background-opacity = 0.9
theme = nord
```

### Orbstack
Sign in to your Orbstack account to restore Docker contexts and Linux VMs.

### Terraform / Pulumi
```bash
# Terraform: restore ~/.terraformrc (managed by chezmoi)
# Pulumi
pulumi login

# Azure
az login
```

---

## 12. Day-to-Day: Keeping Things Updated

### Update all Homebrew packages
```bash
brew update && brew upgrade && brew cleanup
```

### Add a new package
```bash
brew install <package>
brew bundle dump --force   # update Brewfile
chezmoi add ~/path/to/Brewfile
chezmoi apply
```

Or just edit the `Brewfile` in chezmoi directly, then run `brew bundle`.

### Update dotfiles
```bash
chezmoi edit ~/.zshrc    # make changes
chezmoi apply            # apply to ~
chezmoi cd && git add -A && git commit -m "..." && git push
```

### Apply dotfiles on another machine
```bash
chezmoi update    # pulls from git and applies
```

---

## 13. Quick-Start Checklist

### System Bootstrap
- [ ] macOS fully updated
- [ ] Xcode CLI tools installed
- [ ] Rosetta 2 installed
- [ ] Homebrew installed + added to PATH
- [ ] chezmoi installed and dotfiles repo initialized
- [ ] `brew bundle` run with Brewfile
- [ ] `macos-defaults.sh` run, then logged out and back in

### Shell
- [ ] Oh My Zsh installed
- [ ] zsh-autosuggestions, zsh-syntax-highlighting, zsh-autocomplete cloned
- [ ] Pure prompt installed (`npm i -g pure-prompt`)
- [ ] `.zshrc` applied via chezmoi
- [ ] TPM (tmux plugin manager) installed
- [ ] tmux plugins installed (`Ctrl+b` then `I`)

### Identity & Auth
- [ ] 1Password signed in
- [ ] 1Password SSH agent enabled
- [ ] 1Password CLI integration enabled
- [ ] `op signin` completed
- [ ] `~/.ssh/config` in place (pointing to 1Password agent)
- [ ] SSH public keys exported from 1Password to `~/.ssh/`
- [ ] Git configured + commit signing working

### Cloud & IaC
- [ ] `pulumi login` done
- [ ] `az login` done
- [ ] `~/.terraformrc` restored via chezmoi
- [ ] Tailscale connected (from App Store)

### Apps
- [ ] Raycast configured as `⌘ Space`
- [ ] JetBrains Toolbox — IDEs installed
- [ ] Ghostty config applied
- [ ] Orbstack signed in
- [ ] TouchID for sudo enabled

### Fonts
- [ ] JetBrains Mono Nerd Font installed
- [ ] Fira Code Nerd Font installed
- [ ] Ghostty using JetBrainsMono Nerd Font Mono

---

*Managed with Homebrew + chezmoi · Migrated from nix-darwin, April 2026*
