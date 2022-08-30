source $DOTFILES/bashrc

bindkey "^P" up-line-or-search
bindkey "^N" down-line-or-search

if [[ -n $ZSH ]]; then
  export ZSH_CUSTOM="$DOTFILES/oh-my-zsh"
  ZSH_THEME="agnoster-latest"
  plugins=(git)
  source $ZSH/oh-my-zsh.sh
fi

if [[ -n $POWERLINE_ROOT ]]; then
  export POWERLINE_CONFIG_PATHS=$DOTFILES/powerline
  powerline-daemon -q
  source $POWERLINE_ROOT/bindings/zsh/powerline.zsh
fi

setopt HIST_IGNORE_SPACE
