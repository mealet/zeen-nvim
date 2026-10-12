if vim.g.loaded_zeen_lsp then
    return
end

vim.g.loaded_zeen_lsp = 1

if vim.g.zeen_lsp_no_auto_setup then
    return
end

require("zeen-lsp").setup()
