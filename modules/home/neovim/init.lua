vim.cmd [[
    syntax off
    filetype off
    filetype plugin indent off
]]

vim.opt.shadafile = "NONE"

vim.g.loaded_gzip = false
vim.g.loaded_matchit = false
vim.g.loaded_netrwPlugin = false
vim.g.loaded_tarPlugin = false
vim.g.loaded_zipPlugin = false
vim.g.loaded_man = false
vim.g.loaded_2html_plugin = false
vim.g.loaded_remote_plugins = false

vim.defer_fn(function()
    require('configuration')
    require('plugins')

    vim.opt.shadafile = ""
    vim.cmd [[
        rshada!
        doautocmd BufRead
        syntax on
        filetype on
        filetype plugin indent on
        PackerLoad impatient.nvim

        augroup Format
            autocmd!
            autocmd BufWritePost * FormatWrite
        augroup END
    ]]
end, 0)
