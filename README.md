# Ma configuration Neovim

Configuration personnelle de Neovim, écrite en Lua, pensée pour le **développement bas niveau** (C, C++, assembleur x86_64, Rust) et la **cybersécurité** (pwn, reverse).

Elle est utilisée sur deux environnements :

- **macOS** (Apple Silicon)
- **Arch Linux** (VM x86_64)

## Sommaire

- [Aperçu](#aperçu)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Structure du dépôt](#structure-du-dépôt)
- [Plugins](#plugins)
- [Serveurs de langage (LSP)](#serveurs-de-langage-lsp)
- [Raccourcis clavier](#raccourcis-clavier)
- [Modules optionnels](#modules-optionnels)
- [Configuration globale de clangd](#configuration-globale-de-clangd)
- [Problèmes connus](#problèmes-connus)

## Aperçu

- Thème **Catppuccin** et barre d'état **lualine**
- Navigation dans les fichiers, recherche et explorateur avec **Snacks**
- Coloration syntaxique avec **Treesitter**
- Autocomplétion avec **blink.cmp**
- Diagnostics lisibles directement dans le code avec **tiny-inline-diagnostic**
- Déplacements rapides dans le texte avec **leap**
- LSP prêts pour **C/C++** (clangd), **assembleur** (asm-lsp) et **Rust** (rust-analyzer)

## Prérequis

| Outil | Pourquoi |
|---|---|
| **Neovim 0.12 ou plus** | La configuration utilise `vim.pack`, qui n'existe pas dans les versions antérieures |
| `git` | Installation des plugins |
| Un compilateur C et `make` | Compilation de certains plugins |
| Une chaîne Rust (`rustup`) | Compilation de blink.cmp, et installation de `rust-analyzer` et `asm-lsp` |
| `ripgrep` | Recherche de texte dans les fichiers (`<leader>fg`) |
| `lazygit` | Interface Git (`<leader>lg`) |
| Une [Nerd Font](https://www.nerdfonts.com/) dans le terminal | Affichage des icônes |

Vérifie ta version de Neovim avec `nvim --version`.

## Installation

### 1. Sauvegarder une éventuelle configuration existante

```bash
mv ~/.config/nvim ~/.config/nvim.bak
```

### 2. Cloner le dépôt

```bash
git clone https://github.com/<ton-utilisateur>/<ton-depot>.git ~/.config/nvim
```

### 3. Installer les dépendances

**macOS (Homebrew)**

```bash
brew install neovim ripgrep fd lazygit llvm rustup
rustup default stable
rustup component add rust-analyzer
cargo install asm-lsp
```

**Arch Linux**

```bash
sudo pacman -S --needed neovim clang ripgrep fd lazygit bear gdb nasm base-devel git rustup
rustup default stable
rustup component add rust-analyzer
cargo install asm-lsp
```

> Sur Arch, le paquet `clang` fournit aussi `clangd`.

### 4. Premier lancement

Lance `nvim`. `vim.pack` propose d'installer les plugins : accepte, puis **relance Neovim une fois** pour que tout soit chargé.

## Structure du dépôt

```
nvim/
├── init.lua                 # Configuration principale
├── lua/
│   ├── keywords_doc.lua     # Doc des mots-clés C/C++ avec K (optionnel)
│   └── copilot_setup.lua    # Configuration GitHub Copilot (optionnel, désactivée)
├── clangd/
│   ├── config_mac.yaml      # Config globale de clangd pour macOS
│   └── config_arch.yaml     # Config globale de clangd pour Arch Linux
└── README.md
```

## Plugins

Gérés avec le gestionnaire intégré `vim.pack`.

| Plugin | Rôle |
|---|---|
| [catppuccin/nvim](https://github.com/catppuccin/nvim) | Thème de couleurs |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Barre d'état |
| [snacks.nvim](https://github.com/folke/snacks.nvim) | Recherche de fichiers, grep, explorateur, lazygit |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Analyse syntaxique et coloration |
| [tiny-inline-diagnostic.nvim](https://github.com/rachartier/tiny-inline-diagnostic.nvim) | Diagnostics affichés dans le code |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Configurations des serveurs de langage |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Fermeture automatique des parenthèses et guillemets |
| [blink.cmp](https://github.com/saghen/blink.cmp) | Autocomplétion |
| [leap.nvim](https://codeberg.org/andyg/leap.nvim) | Déplacements rapides dans le texte |

## Serveurs de langage (LSP)

| Langage | Serveur | Installation |
|---|---|---|
| C / C++ | `clangd` | Paquet `clang` (Arch) ou `llvm` (Homebrew) |
| Assembleur | `asm-lsp` | `cargo install asm-lsp` |
| Rust | `rust-analyzer` | `rustup component add rust-analyzer` |

Pour les projets C/C++ de plusieurs fichiers, génère un `compile_commands.json` à la racine du projet pour que clangd connaisse les options de compilation :

```bash
bear -- make
```

## Raccourcis clavier

La touche **leader** est `k`.

### Recherche et navigation

| Raccourci | Action |
|---|---|
| `<leader>ff` | Chercher un fichier |
| `<leader>fg` | Chercher un texte dans tous les fichiers |
| `<leader>fb` | Liste des buffers ouverts |
| `<leader>fe` | Explorateur de fichiers |
| `<leader>fs` | Symboles du fichier courant |
| `<leader>fS` | Symboles de tout le projet |
| `s` | Leap : sauter dans la fenêtre courante |
| `S` | Leap : sauter dans une autre fenêtre |

### Code et LSP

| Raccourci | Action |
|---|---|
| `<leader>fd` | Liste des diagnostics (erreurs et avertissements) |
| `<leader>fm` | Formater le fichier |
| `K` | Documentation du symbole sous le curseur |
| `gd` | Aller à la définition |
| `grr` | Lister les références |
| `grn` | Renommer le symbole |
| `gra` | Actions de code |

### Git

| Raccourci | Action |
|---|---|
| `<leader>lg` | Ouvrir lazygit |

### Autocomplétion (mode insertion)

| Touche | Action |
|---|---|
| `Tab` | Suggestion suivante |
| `Shift+Tab` | Suggestion précédente |
| `Entrée` | Accepter la suggestion |
| `Échap` | Fermer le menu |

## Modules optionnels

Ces fichiers sont dans `lua/` et se chargent chacun avec **une seule ligne** à la fin de `init.lua`. Pour les désactiver, il suffit de commenter la ligne.

### Doc des mots-clés C/C++

```lua
require("keywords_doc")
```

`K` sur un mot-clé (`return`, `unsigned`, `static`...) affiche une fiche explicative, avec les pièges de sécurité classiques. Sur tout autre mot, `K` interroge clangd.

Pour ajouter une fiche, ajoute une ligne `["mot"] = "description",` dans la table `docs` du fichier.

### GitHub Copilot (désactivé)

```lua
-- require("copilot_setup")
```

Les suggestions automatiques y sont éteintes par défaut, et Copilot est désactivé sur les fichiers assembleur. Après activation, authentifie-toi une fois avec `:Copilot auth`.

## Configuration globale de clangd

Les fichiers du dossier `clangd/` sont à copier **en dehors** du dépôt, à l'emplacement que clangd lit selon le système.

**macOS**

```bash
mkdir -p ~/Library/Preferences/clangd
cp ~/.config/nvim/clangd/config_mac.yaml ~/Library/Preferences/clangd/config.yaml
```

**Arch Linux**

```bash
mkdir -p ~/.config/clangd
cp ~/.config/nvim/clangd/config_arch.yaml ~/.config/clangd/config.yaml
```

Ils activent `-Wall -Wextra` ainsi que des vérifications clang-tidy (`bugprone`, `clang-analyzer`, `cert`). Un fichier `.clangd` à la racine d'un projet reste prioritaire.

## Problèmes connus

### La compilation de blink.cmp échoue dans une VM émulée

Sur une VM x86_64 émulée (UTM sur Apple Silicon), l'éditeur de liens `lld` utilisé par Rust peut planter (`Segmentation fault`). Pour utiliser l'éditeur de liens classique, ajoute dans `~/.cargo/config.toml` :

```toml
[target.x86_64-unknown-linux-gnu]
rustflags = ["-C", "link-arg=-fuse-ld=bfd"]
```

Puis supprime le dossier `~/.local/share/nvim/site/pack/core/opt/blink.cmp/target` et relance Neovim.

### Fausses erreurs d'inclusion dans un projet C

clangd ne trouve pas `compile_commands.json`. Génère-le avec `bear -- make` à la racine du projet et ouvre Neovim depuis ce dossier.

### `K` ne répond rien sur un mot-clé

Sans le module `keywords_doc`, clangd ne documente pas les mots-clés du langage (`return`, `int`...). Active le module décrit plus haut.

### Le leader `k` ralentit les déplacements

`k` sert aussi à monter d'une ligne : Neovim attend un court instant pour savoir si c'est un raccourci. Si ça gêne, change le leader dans `init.lua` (`vim.g.mapleader`), par exemple pour `<Space>`.
