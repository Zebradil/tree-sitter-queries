# Tree Sitter Queries Library for Neovim

A modular collection of Tree-sitter injection and highlight queries for Neovim, designed for selective installation.

## Features

- 🎯 **Selective loading** — install only the modules you need
- 🔌 **Custom directives** — modules can include custom Tree-sitter directives and predicates
- 📦 **Self-contained** — each module bundles its queries and directives together
- ⚡ **Lazy-load ready** — integrates seamlessly with lazy.nvim

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

## Configuration

### Options

```lua
require("ts-queries").setup({
  modules = {}, -- List of module names to enable
})
```

### Available Modules

| Module      | Language | Description                                                                       |
| ----------- | -------- | --------------------------------------------------------------------------------- |
| `yaml-lang` | YAML     | Injects various languages in YAML files based on comments (e.g., `# lang:python`) |

> Run `:lua print(vim.inspect(require("ts-queries").list_modules()))` to list all available modules.

## Adding New Modules

### 1. Create Module Directory

```
modules/
└── <module-name>/
    ├── queries/
    │   └── <language>/
    │       ├── injections.scm
    │       └── highlights.scm
    └── after/
        └── queries/
            └── <language>/
                └── highlights.scm   # If extending existing highlights
```

### 2. Query Files

For queries that extend existing ones, add `;extends` at the top:

```scheme
;extends

; Your query patterns here
((comment) @injection.content
  (#match? @injection.content "^#@")
  (#set! injection.language "your_language"))
```

### 3. File Placement

| Purpose                    | Location                              |
| -------------------------- | ------------------------------------- |
| New language queries       | `queries/<language>/`                 |
| Extending existing queries | `queries/<language>/` with `;extends` |
| Override/load after others | `after/queries/<language>/`           |

## Adding Custom Directives

If your module requires custom Tree-sitter directives or predicates, create a directive file:

### 1. Create Directive File

`lua/ts-queries/directives/<module-name>.lua`:

```lua
local M = {}

M.setup = function()
  -- Add a custom directive
  vim.treesitter.query.add_directive(
    "your-directive!",
    function(match, _, bufnr, predicate, metadata)
      -- Directive logic
    end,
    { force = true }
  )

  -- Add a custom predicate
  vim.treesitter.query.add_predicate(
    "your-predicate?",
    function(match, _, bufnr, predicate)
      -- Predicate logic
      return true
    end,
    { force = true }
  )
end

return M
```

### 2. Use in Queries

```scheme
;extends

((comment) @injection.content
  (#your-predicate? @injection.content)
  (#your-directive! @injection.content)
  (#set! injection.language "target_language"))
```

The directive file is automatically loaded when the module is enabled, before queries are added to the runtime path.

## Troubleshooting

### Queries not loading

1. Verify the module is enabled:

   ```lua
   :lua print(vim.inspect(require("ts-queries").list_modules()))
   ```

2. Check runtime path includes the module:

   ```lua
   :lua print(vim.o.rtp)
   ```

3. Inspect active queries:
   ```vim
   :InspectTree
   ```

### Directives not found

Ensure the plugin loads before opening relevant files. Add `priority = 100` to your Lazy spec if needed:

```lua
{
  "yourusername/ts-queries-library",
  priority = 100,
  opts = { modules = { "your-module" } },
}
```

### Query conflicts

If queries conflict with other plugins, move them to `after/queries/`:

```
modules/<module-name>/after/queries/<language>/injections.scm
```

## Project Structure

```
tree-sitter-queries/
├── lua/
│   └── ts-queries/
│       ├── init.lua              # Main setup logic
│       └── directives/           # Custom directives per module
│           ├── init.lua
│           └── <module-name>.lua
├── modules/                      # Query modules
│   └── <module-name>/
│       ├── queries/
│       │   └── <language>/
│       │       └── *.scm
│       └── after/
│           └── queries/
│               └── <language>/
│                   └── *.scm
├── README.md
└── LICENSE
```

## License

MIT
