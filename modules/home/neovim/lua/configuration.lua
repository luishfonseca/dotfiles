-- Configuration file for Luís' configuration
local neolhf = require('neolhf')

-- Set the leader to <Space>
vim.g.mapleader = " "

-- General configuration
vim.opt.termguicolors = true
vim.opt.showmode = false

-- Enable mouse support
vim.opt.mouse = 'a'
vim.opt.mousefocus = true

-- Enable line numbers and relative numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Used by which-key.nvim
vim.opt.timeoutlen = 500

-- Update the editor more frequently
vim.opt.updatetime = 100

-- Start scrolling when we are 5 lines away from margins
vim.opt.scrolloff = 5

-- Disable wrapping
vim.opt.wrap = false

-- Make vim's default splitting directions something reasonable
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Synchronize the system clipboard with neovim's
vim.opt.clipboard = "unnamedplus"

-- Make sure the statusline is always shown
vim.opt.laststatus = 2

-- Print shorter messages
vim.opt.shortmess:append("c")

-- Stop neovim from waiting after escape has been pressed
vim.opt.ttimeoutlen = 5

-- Set up indenting
vim.opt.expandtab = false
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- Allow us to edit text that doesn't classify as characters
-- in visual block mode
vim.opt.virtualedit = "block"

-- Set up the undofile directory
vim.opt.undodir = os.getenv("XDG_CACHE_HOME") .. "/nvim/undo"

-- Show previews for substitutions etc.
vim.opt.inccommand = "split"

-- Set conceal level for neorg
vim.opt.conceallevel = 2

function neolhf:on_file_enter()

    -- Enable undo files for every buffer
    vim.opt.undofile = true

    -- Enable smart indentation
    vim.opt.autoindent = true
    vim.opt.smartindent = true
    vim.opt.copyindent = true
    vim.opt.preserveindent = true

    vim.cmd [[
        if line("'\"") > 1 && line("'\"") <= line("$") |
        exe "normal! g'\"" |
        endif
    ]]
end

vim.cmd [[
    autocmd FileType * :lua require('neolhf').on_file_enter()
]]
