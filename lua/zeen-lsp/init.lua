local M = {}

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

function M.setup(opts)
    opts = opts or {}

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "zeen",
        callback = function(args)
            local cmd = resolve_cmd(opts)

            if not cmd then
                return
            end

            local bufname = vim.api.nvim_buf_get_name(args.buf)
            local root_dir = vim.fs.root(bufname, opts.root_markers or { ".git" })
                or vim.fs.dirname(bufname)

            vim.lsp.start({
                name = "zeen-lsp",
                cmd = cmd,
                root_dir = root_dir,
            })

            if opts.inlay_hints ~= false then
                vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
            end
        end,
    })
end

return M
