local M = {}

M.setup = function()
  -- vim.treesitter.query.add_directive("ytt-some-directive!", function(match, _, _, predicate, metadata)
  --   -- Your directive logic
  -- end, { force = true })
  --
  -- vim.treesitter.query.add_predicate("ytt-some-predicate?", function(match, _, _, predicate)
  --   -- Your predicate logic
  --   return true
  -- end, { force = true })

  vim.treesitter.query.add_directive("offset-first-line!", function(match, _, _, pred, metadata)
    local capture_id = pred[2]
    local node = match[capture_id]
    if not node then return end

    local start_row, _, end_row, end_col = node:range()

    -- Move to next line, column 0
    metadata[capture_id] = metadata[capture_id] or {}
    metadata[capture_id].range = { start_row + 1, 0, end_row, end_col }
  end, { force = true })
end

return M
