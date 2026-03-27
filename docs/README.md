# Tree Sitter Queries Library for Neovim

A modular collection of Tree-sitter injection and highlight queries for Neovim, designed for selective installation.

## Features

- 🎯 **Selective loading** — install only the modules you need
- 🔌 **Custom directives** — modules can include custom Tree-sitter directives and predicates
- 📦 **Self-contained** — each module bundles its queries and directives together
- ⚡ **Lazy-load ready** — integrates seamlessly with lazy.nvim

## Available Modules

| Module          | Language | Description                                                                       |
| --------------- | -------- | --------------------------------------------------------------------------------- |
| [`yaml-lang`][] | YAML     | Injects various languages in YAML files based on comments (e.g., `# lang:python`) |

[`yaml-lang`]: ../modules/yaml-lang/README.md

## Requirements

- Neovim >= 0.9.0
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "zebradil/tree-sitter-queries",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    modules = {
      "yaml-lang",
      -- Add more modules as needed
    },
  },
}
```

### Nix

**Step 1.** Add the flake input:

```nix
# flake.nix
{
  inputs.tree-sitter-queries.url = "github:zebradil/tree-sitter-queries";
}
```

**Step 2.** Apply the overlay:

```nix
nixpkgs.overlays = [
  inputs.tree-sitter-queries.overlays.default
];
```

**Step 3.** Add the plugin to your Neovim configuration:

```nix
# Add to extraPlugins
pkgs.vimPlugins.tree-sitter-queries-nvim
```

## Configuration

### Options

```lua
require("ts-queries").setup({
  modules = {}, -- List of module names to enable
})
```

> [!TIP]  
> Run `:lua print(vim.inspect(require("ts-queries").list_modules()))` to list all available modules.
