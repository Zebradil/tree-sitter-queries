local M = {}

local plugin_path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h")
local modules_path = plugin_path .. "/modules"

local loaded_modules = {}

local function load_module(name)
  if loaded_modules[name] then return end

  local module_path = modules_path .. "/" .. name

  if vim.fn.isdirectory(module_path) == 0 then
    vim.notify("ts-queries: module not found: " .. name, vim.log.levels.WARN)
    return
  end

  -- Load module config and register directives
  local config_path = module_path .. "/init.lua"
  if vim.fn.filereadable(config_path) == 1 then
    local config = dofile(config_path)
    if config.setup then config.setup() end
  end

  -- Add module to rtp for queries/
  local queries_path = module_path .. "/queries"
  if vim.fn.isdirectory(queries_path) == 1 then vim.opt.rtp:prepend(module_path) end

  -- Add after/ to end of rtp for after/queries/
  local after_path = module_path .. "/after"
  if vim.fn.isdirectory(after_path) == 1 then vim.opt.rtp:append(after_path) end

  loaded_modules[name] = true
end

M.list_modules = function()
  if vim.fn.isdirectory(modules_path) == 0 then return {} end
  return vim.fn.readdir(modules_path, function(entry) return vim.fn.isdirectory(modules_path .. "/" .. entry) == 1 end)
end

M.setup = function(opts)
  opts = opts or {}
  local enabled_modules = opts.modules or {}

  for _, name in ipairs(enabled_modules) do
    load_module(name)
  end
end

M.load = load_module
M.is_loaded = function(name) return loaded_modules[name] == true end

return M
