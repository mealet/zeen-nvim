local M = {}

local AUGROUP = "ZeenTreesitter"

local function register_parser_legacy()
    -- nvim-treesitter classic branch (parsers.get_parser_configs).
    -- На новом main-бранче модуля нет — тихо пропускаем.
    local ok, parsers = pcall(require, "nvim-treesitter.parsers")

    if not ok or type(parsers.get_parser_configs) ~= "function" then
        return
    end

    local parser_configs = parsers.get_parser_configs()

    if parser_configs.zeen == nil then
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
end

local function register_language()
    -- Связываем filetype=zeen с treesitter-языком zeen (парсер ищется
    -- в runtimepath: parser/zeen.so). Без этого vim.treesitter.start
    -- не знает какой парсер брать.
    if vim.treesitter.language and vim.treesitter.language.register then
        pcall(vim.treesitter.language.register, "zeen", "zeen")
    end
end

function M.setup()
    register_language()
    register_parser_legacy()

    local group = vim.api.nvim_create_augroup(AUGROUP, { clear = true })

    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "TSUpdate",
        callback = register_parser_legacy,
    })

    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "zeen",
        callback = function(args)
            -- Не падаем если парсер еще не собран (parser/zeen.so отсутствует).
            pcall(vim.treesitter.start, args.buf, "zeen")
        end,
    })

    -- См. комментарий в zeen-lsp.setup: добираем буферы, открытые
    -- до вызова setup (ленивая загрузка по `ft = "zeen"`).
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == "zeen" then
            pcall(vim.treesitter.start, bufnr, "zeen")
        end
    end
end

return M
