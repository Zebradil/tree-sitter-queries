local M = {}

-- Module metadata
M.filetypes = { "yaml" }

M.setup = function()
  -- Directive to offset first line of a capture's range to the next line, while resetting column to 0
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
