#!/bin/bash
#######################################################################
# To properly integrate with dotfiles, add this to the top of your
# $HOME/.bash_profile:
#
#   export DOTFILES=/path/to/dotfiles
#
#   source $DOTFILES/bash_profile
#
#   if [ -f $HOME/.bashrc ]; then
#     source $HOME/.bashrc
#   fi
#
# Then, place any machine-specific settings login settings in
# $HOME/.bash_profile
#######################################################################

if [ -z "${ORIGINAL_PATH+x}" ]; then
   export ORIGINAL_PATH=$PATH
fi

# Reattach to a screen session if it's running and not already attached
function f_rescreen {
  if [ "$(screen -ls | grep Attached)" == "" ]; then
    screen -aAdR
  fi
}
alias rescreen="f_rescreen"

# Reattach to a known tmux session if it's running and not already attached
function f_retmux {
  [ ! -z "${TMUX+x}" ] && return

  local session_name=persist
  local has_session=$(tmux has-session -t $session_name >/dev/null 2>&1)$?

  if [[ $has_session == 0 && "$(tmux list-clients -t $session_name -F '#{?session_attached,attached,}')" != "attached" ]]; then
    tmux attach-session -t $session_name
  elif [[ $has_session != 0 ]]; then
    tmux new-session -s $session_name
  fi
}
alias retmux="f_retmux"
