let rootpath="$DOTFILES/nvim"
execute "set runtimepath^=".rootpath
execute "set runtimepath+=".rootpath."/after"
execute "source ".rootpath."/lua/init.lua"
execute "source ".rootpath."/plug.vim"
