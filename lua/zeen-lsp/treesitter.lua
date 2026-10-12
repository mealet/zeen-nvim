local M = {}

local function register_parser()
    local ok, parsers = pcall(
        require,
        "nvim-treesitter.parsers"
    )

    if not ok then
        return
    end

    local parser_configs = parsers.get_parser_configs()

    parser_configs.zeen = {
        install_info = {
            url = "https://github.com/mealet/zeen-treesitter",
            branch = "main",
            files = { "src/parser.c" },
            generate_requires_npm = false,
            requires_generate_from_grammar = false,
        },
        filetype = "zeen",
    }
end

function M.setup()
    register_parser()

    vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = register_parser,
    })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "zeen",
        callback = function(args)
            pcall(vim.treesitter.start, args.buf, "zeen")
        end,
    })
end

return M
