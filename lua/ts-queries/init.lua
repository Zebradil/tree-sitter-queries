local M = {}

M.setup = function(opts)
  opts = opts or {}
  local modules = opts.modules or {}

  local plugin_path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h")

  for _, module in ipairs(modules) do
    -- 1. Register directives FIRST
    local directive_ok, directive = pcall(require, "ts-queries.directives." .. module)
    if directive_ok and directive.setup then directive.setup() end

    -- 2. Then add queries to rtp
    local module_path = plugin_path .. "/modules/" .. module
    if vim.fn.isdirectory(module_path) == 1 then
      vim.opt.rtp:prepend(module_path)
      local after_path = module_path .. "/after"
      if vim.fn.isdirectory(after_path) == 1 then vim.opt.rtp:append(after_path) end
    else
      vim.notify("ts-queries: module not found: " .. module, vim.log.levels.WARN)
    end
  end
end

return M
