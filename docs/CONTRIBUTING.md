## Adding New Modules

### 1. Create Module Directory

```
modules/
└── <module-name>/
    ├── init.lua                  # Module metadata + custom directives
    ├── queries/
    │   └── <language>/
    │       ├── injections.scm
    │       └── highlights.scm
    └── after/
        └── queries/
            └── <language>/
                └── highlights.scm   # If extending existing highlights
```

### 2. Create Module Config

`modules/<module-name>/init.lua`:

```lua
local M = {}

-- Required: list of filetypes that trigger this module
M.filetypes = { "yaml" }

-- Optional: list of required tree-sitter parsers
M.parsers = { "yaml" }

-- Optional: setup function for custom directives/predicates
M.setup = function()
  -- See "Adding Custom Directives" below
end

return M
```

### 3. Add Query Files

For queries that extend existing ones, add `;extends` at the top:

```scheme
;extends

; Your query patterns here
((comment) @injection.content
  (#match? @injection.content "^#@")
  (#set! injection.language "your_language"))
```

### 4. File Placement

| Purpose                    | Location                              |
| -------------------------- | ------------------------------------- |
| New language queries       | `queries/<language>/`                 |
| Extending existing queries | `queries/<language>/` with `;extends` |
| Override/load after others | `after/queries/<language>/`           |

## Adding Custom Directives

If your module requires custom Tree-sitter directives or predicates, add them to the module's `setup()` function:

`modules/<module-name>/init.lua`:

```lua
local M = {}

M.filetypes = { "yaml" }

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

Use in queries:

```scheme
;extends

((comment) @injection.content
  (#your-predicate? @injection.content)
  (#your-directive! @injection.content)
  (#set! injection.language "target_language"))
```

The `setup()` function is automatically called when the module is loaded, before queries are added to the runtime path.

## Troubleshooting

### Queries not loading

1. Verify the module is enabled:

   ```lua
   :lua print(vim.inspect(require("ts-queries").list_modules()))
   ```

2. Check if the module is loaded:

   ```lua
   :lua print(require("ts-queries").is_loaded("your-module"))
   ```

3. Manually load a module for debugging:

   ```lua
   :lua require("ts-queries").load("your-module")
   ```

4. Inspect active queries:

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

### Lazy loading not working

Verify your module's `init.lua` exports the `filetypes` field:

```lua
-- modules/<module-name>/init.lua
local M = {}
M.filetypes = { "yaml" }  -- Required for lazy loading
return M
```

## Project Structure

```
ts-queries-library/
├── lua/
│   └── ts-queries/
│       └── init.lua              # Main setup logic
├── modules/                      # Query modules
│   └── <module-name>/
│       ├── init.lua              # Module metadata + directives
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
