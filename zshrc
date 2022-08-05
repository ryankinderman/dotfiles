bindkey -e

# Load Git completion
zstyle ':completion:*:*:git:*' script $DOTFILES/bash/git-completion.bash
fpath=($DOTFILES/zsh $fpath)

autoload -Uz compinit && compinit

PS1='%~ %# '

# Include git branch in prompt

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
#RPROMPT='${vcs_info_msg_0_}'
PROMPT='%~(${vcs_info_msg_0_})%# '
zstyle ':vcs_info:git:*' formats '%b'
