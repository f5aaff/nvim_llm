local M = {}


-- Function to read the line under the cursor and write something below it
function M.add_line_below()
  -- Get the current line under the cursor
  local current_line = vim.api.nvim_get_current_line()

  -- Process the current line or generate new content based on it
  -- Example: adding the current line's content in a new way
  local new_content = "Here is the new line, based on: " .. current_line

  -- Insert the new content below the current line
  vim.api.nvim_put({ new_content }, 'l', false, true)

  -- Move cursor to the new line (one below the current line)
  vim.api.nvim_win_set_cursor(0, { vim.fn.line('.') + 1, 0 })
end

return M
