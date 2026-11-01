#!/bin/bash
sudo dnf install -y nodejs npm pip podman
pip install ansible-lint ansible-navigator
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cat <<EOF > ~/.vimrc
" --- Vim-Plug Section ---
call plug#begin('~/.vim/plugged')

Plug 'morhetz/gruvbox'                              " Theme
Plug 'itchyny/lightline.vim'                         " Clean status bar
Plug 'Yggdroot/indentLine'                           " Vertical indent lines for YAML
Plug 'pearofducks/ansible-vim'                       " Official Ansible syntax & Jinja2
Plug 'tpope/vim-commentary'                          " Comment toggling (gcc)
Plug 'tpope/vim-surround'                            " Bracket/quote manipulation
Plug 'neoclide/coc.nvim', {'branch': 'release'}      " LSP client

call plug#end()

" --- Core UI & Behavior ---
syntax on
filetype plugin indent on

set background=dark
silent! colorscheme gruvbox

set number
set relativenumber
set cursorline
set hidden
set updatetime=300
set shortmess+=c
set signcolumn=yes

" --- Strict 2-Space YAML Indentation ---
set expandtab
set shiftwidth=2
set tabstop=2
set softtabstop=2
set autoindent

" Highlight tabs and trailing whitespace
set list
set listchars=tab:▸\ ,trail:•,extends:❯,precedes:❮,nbsp:␣

" --- Ansible Filetype Association ---
augroup ansible_ft
  autocmd!
  autocmd BufNewFile,BufRead *.yml,*.yaml,*/tasks/*.yml,*/handlers/*.yml,site.yml setfiletype yaml.ansible
  autocmd FileType yaml.ansible setlocal ts=2 sts=2 sw=2 expandtab indentkeys-=0#
augroup END

" --- Plugin Options ---
let g:ansible_unindent_after_newline = 1
let g:ansible_attribute_highlight = "ob"
let g:indentLine_char = '│'
let g:indentLine_fileType = ['yaml', 'yml', 'yaml.ansible']

" --- CoC Extensions (Do NOT include coc-ansible or coc-yaml) ---
let g:coc_global_extensions = [
  \ 'coc-snippets'
  \ ]

" Tab navigation for autocomplete popup
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Enter confirms completion
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

" Leader Key (Space)
let mapleader = " "

" Press 'K' to show module documentation
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Jump to next/prev lint diagnostic
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
EOF

cat <<EOF > ~/.vim/coc-settings.json
{
  "languageserver": {
    "ansible": {
      "command": "ansible-language-server",
      "args": ["--stdio"],
      "filetypes": ["yaml.ansible", "ansible"],
      "rootPatterns": [
        "ansible.cfg",
        ".ansible-lint",
        "galaxy.yml",
        ".git"
      ],
      "settings": {
        "ansible": {
          "ansible": {
            "path": "ansible"
          },
          "ansibleLint": {
            "enabled": true,
            "path": "ansible-lint"
          },
          "executionEnvironment": {
            "enabled": false
          },
          "python": {
            "interpreterPath": "python3"
          },
          "validation": {
            "enabled": true,
            "lint": {
              "enabled": true,
              "path": "ansible-lint"
            }
          }
        }
      }
    }
  }
}
EOF

rm -rf ~/.config/coc/extensions/coc-yaml-data/
vim -es -u ~/.vimrc -c "PlugInstall" -c "qa"
echo export ANSIBLE_PYTHON_INTERPRETER=auto_silent >> ~/.bashrc
