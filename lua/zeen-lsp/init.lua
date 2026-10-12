local M = {}

local AUGROUP = "ZeenLsp"

local function resolve_cmd(opts)
    if opts.cmd then
        return opts.cmd
    end

    if vim.fn.executable("zeen-lsp") == 1 then
        return { "zeen-lsp" }
    end

    vim.notify(
        "[zeen-lsp] binary not found: install it into PATH or set cmd explicitly",
        vim.log.levels.ERROR
    )

    return nil
end

local function resolve_root(bufname, root_markers)
    if bufname == "" then
        return vim.fn.getcwd()
    end
    return vim.fs.root(bufname, root_markers) or vim.fs.dirname(bufname)
end

local function attach_existing(bufnr, root_dir)
    for _, client in ipairs(vim.lsp.get_clients({ name = "zeen-lsp" })) do
        local dir = client.config and client.config.root_dir
        if dir == root_dir then
            vim.lsp.buf_attach_client(bufnr, client.id)
            return true
        end
    end
    return false
end

function M.setup(opts)
    opts = opts or {}

    vim.filetype.add({
        extension = {
            zn = "zeen",
        },
    })

    require("zeen-lsp.treesitter").setup()

    local group = vim.api.nvim_create_augroup(AUGROUP, { clear = true })

    local function on_zeen_buffer(bufnr)
        local cmd = resolve_cmd(opts)

        if not cmd then
            return
        end

        local bufname = vim.api.nvim_buf_get_name(bufnr)
        local root_dir = resolve_root(bufname, opts.root_markers or { ".git", "Zora.toml", "Zora.lock" })

        if attach_existing(bufnr, root_dir) then
            return
        end

        vim.lsp.start({
            name = "zeen-lsp",
            cmd = cmd,
            root_dir = root_dir,
        })

        if opts.inlay_hints ~= false then
            pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
        end
    end

    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "zeen",
        callback = function(args)
            on_zeen_buffer(args.buf)
        end,
    })

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == "zeen" then
            on_zeen_buffer(bufnr)
        end
    end
end

return M
