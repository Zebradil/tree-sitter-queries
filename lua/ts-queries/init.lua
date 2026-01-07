local M = {}

local plugin_path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h")
local modules_path = plugin_path .. "/modules"

-- Cache for loaded modules
local loaded_modules = {}

-- Load a single module
local function load_module(name)
  if loaded_modules[name] then return end

  local module_path = modules_path .. "/" .. name

  if vim.fn.isdirectory(module_path) == 0 then
    vim.notify("ts-queries: module not found: " .. name, vim.log.levels.WARN)
    return
  end

  -- Load module config
  local config_path = module_path .. "/init.lua"
  local has_config = vim.fn.filereadable(config_path) == 1

  if has_config then
    -- Load and execute module's init.lua
    local config = dofile(config_path)

    -- Register directives first
    if config.setup then config.setup() end
  end

  -- Add queries to rtp
  vim.opt.rtp:prepend(module_path)

  -- Handle after/ directory
  local after_path = module_path .. "/after"
  if vim.fn.isdirectory(after_path) == 1 then vim.opt.rtp:append(after_path) end

  loaded_modules[name] = true
end

-- Get module metadata without full loading
local function get_module_info(name)
  local config_path = modules_path .. "/" .. name .. "/init.lua"
  if vim.fn.filereadable(config_path) == 1 then return dofile(config_path) end
  return {}
end

-- List available modules
M.list_modules = function()
  if vim.fn.isdirectory(modules_path) == 0 then return {} end
  return vim.fn.readdir(modules_path, function(entry) return vim.fn.isdirectory(modules_path .. "/" .. entry) == 1 end)
end

-- Main setup
M.setup = function(opts)
  opts = opts or {}
  local enabled_modules = opts.modules or {}
  local lazy_load = opts.lazy ~= false -- Default: true

  if not lazy_load then
    -- Load all modules immediately
    for _, name in ipairs(enabled_modules) do
      load_module(name)
    end
    return
  end

  -- Build filetype -> modules map
  local ft_modules = {}
  for _, name in ipairs(enabled_modules) do
    local info = get_module_info(name)
    local filetypes = info.filetypes or {}

    for _, ft in ipairs(filetypes) do
      ft_modules[ft] = ft_modules[ft] or {}
      table.insert(ft_modules[ft], name)
    end
  end

  -- Create autocmds for lazy loading
  for ft, modules in pairs(ft_modules) do
    vim.api.nvim_create_autocmd("FileType", {
      pattern = ft,
      once = true,
      callback = function()
        for _, name in ipairs(modules) do
          load_module(name)
        end

        -- Invalidate query cache for this language
        vim.treesitter.query.invalidate_query(ft, "injections")
        vim.treesitter.query.invalidate_query(ft, "highlights")

        -- Reattach treesitter to all buffers with this filetype
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == ft then
            local lang = vim.treesitter.language.get_lang(ft) or ft

            -- Stop existing treesitter
            vim.treesitter.stop(buf)

            -- Restart treesitter
            pcall(vim.treesitter.start, buf, lang)
          end
        end
      end,
    })
  end
end

-- Manually load a module (for debugging or dynamic loading)
M.load = load_module

-- Check if module is loaded
M.is_loaded = function(name) return loaded_modules[name] == true end

return M
