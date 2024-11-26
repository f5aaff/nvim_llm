local M = {}

-- Default configuration
M.config = {
    nvim_llm_bin = "~/.local/share/nvim/site/pack/packer/start/nvim_llm/lua/nvim_llm/nvim_llm/nvim_llm",
    nvim_llm_conf = "~/.local/share/nvim/site/pack/packer/start/nvim_llm/lua/nvim_llm/nvim_llm/codellama.json"
}

local function load_lua_config(path)
    local config, err = loadfile(path)
    if not config then
        error("Failed to load config file: " .. err)
    end
    return config()
end

-- Load configuration from a file
function M.setup(config_path)
    local config = load_lua_config(config_path) -- or load_json_config(config_path)
    if config then
        M.config = vim.tbl_deep_extend("force", M.config, config)
    end
end

local function get_script_dir()
    local info = debug.getinfo(1, "S")           -- Get the script information
    local script_path = info.source:sub(2)       -- Remove the '@' at the start of the path
    return vim.fn.fnamemodify(script_path, ":h") -- Get the directory of the script
end
local function load_default_config()
    local script_dir = get_script_dir()
    local config_path = script_dir .. "/config.json" -- Path to config.json

    local file = io.open(config_path, "r")
    if not file then
        error("Config file not found at: " .. config_path)
    end

    local json = file:read("*all")
    file:close()
    return vim.fn.json_decode(json)
end

-- Example function using the configuration
function M.show_config()
    print(vim.inspect(M.config))
end

-- Function to read the line under the cursor and write something below it
function M.gen_code()
    local config = load_default_config()
    M.config = vim.tbl_deep_extend("force", M.config, config)
    local nvim_llm_bin = M.config.nvim_llm_bin
    local nvim_llm_conf = M.config.nvim_llm_conf
    -- Get the current line under the cursor
    local current_line = vim.api.nvim_get_current_line()

    -- run the nvim_llm binary with the given params and current line as the query
    local handle = io.popen(
        nvim_llm_bin .. " -c" .. nvim_llm_conf .. " -m \"" ..
        current_line .. "\"")

    local new_content = handle:read("*a") -- Read the output
    handle:close()

    -- iterate over the response, creating a new line everytime a newline is encountered.
    local lines = {}
    for line in new_content:gmatch("([^\n]*)\n?") do
        table.insert(lines, line)
    end
    -- Get the current cursor position and total lines in the buffer
    local cursor_pos = vim.fn.line('.')
    local total_lines = vim.fn.line('$')

    -- Calculate the insertion point, ensuring it doesn't exceed the buffer size
    local insertion_point = math.min(cursor_pos, total_lines)

    -- Insert the lines, ensuring we don't try to go past the last line
    vim.api.nvim_buf_set_lines(0, insertion_point, insertion_point, false, lines)

    -- Move the cursor to the last inserted line
    local last_inserted_line = math.min(insertion_point + #lines, vim.fn.line('$'))
    vim.api.nvim_win_set_cursor(0, { last_inserted_line, 0 })
end

return M
