" From https://github.com/junegunn/vim-plug/

call plug#begin()

Plug 'nvim-lua/plenary.nvim' " depended on by telescope
Plug 'nvim-telescope/telescope.nvim'

Plug 'rose-pine/neovim'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-obsession'

Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'nvim-treesitter/playground'

" LSP Support
Plug 'neovim/nvim-lspconfig'             " Required
Plug 'williamboman/mason.nvim',          " Optional
Plug 'williamboman/mason-lspconfig.nvim' " Optional
Plug 'mfussenegger/nvim-jdtls'

" Autocompletion
Plug 'hrsh7th/nvim-cmp'     " Required
Plug 'hrsh7th/cmp-nvim-lsp' " Required
Plug 'L3MON4D3/LuaSnip'     " Required

Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v3.x'}

" Syntax support

" NOTE: using this for :Toc and other commands; using treesitter for syntax
" highlighting and folding
Plug 'preservim/vim-markdown' 
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }
Plug 'https://github.com/apple/pkl-neovim.git'
Plug 'lilyinstarlight/vim-spl'

" Tools
Plug 'mileszs/ack.vim'

" Initialize plugin system
" - Automatically executes `filetype plugin indent on` and `syntax enable`.
call plug#end()
" You can revert the settings after the call like so:
"   filetype indent off   " Disable file-type-specific indentation
"   syntax off            " Disable syntax highlighting
