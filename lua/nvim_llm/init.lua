local M = {}

function M.run_nvim_llm()
end

-- Function to read the line under the cursor and write something below it
function M.gen_code()
    -- Get the current line under the cursor
    local current_line = vim.api.nvim_get_current_line()
    local handle = io.popen("./nvim_llm/nvim_llm -c ./nvim_llm/codellama.json -m " .. current_line)
    local new_content = handle:read("*a") -- Read the output
    handle:close()

    -- Insert the new content below the current line
    vim.api.nvim_put({ new_content }, 'l', false, true)

    -- Move cursor to the new line (one below the current line)
    vim.api.nvim_win_set_cursor(0, { vim.fn.line('.') + 1, 0 })
end

return M
