#!/bin/bash
source $DOTFILES/bash/utils.bash

in_login_shell() {
  if [[ "$(shopt login_shell)" =~ "off" ]]; then echo 1; else echo 0; fi
}

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
  # Shell is non-interactive.  Be done now!
  return
fi

if [ "$ORIGINAL_PATH" = "" ]; then
   export ORIGINAL_PATH=$PATH
fi

PS1="\h:\u \W\$(parse_git_branch)\$ "

PATH=$ORIGINAL_PATH
export PATH=$HOME/bin:$DOTFILES/bin:$HOME/installs/bin:$HOME/bin/wireshark:$HOME/bin/flex/bin:/usr/local/texlive/2008/bin/universal-darwin:/opt/local/bin:/usr/local/mysql/bin:$HOME/.gem/ruby/1.8/bin:$ORIGINAL_PATH
export MANPATH=/opt/local/man:$MANPATH
export EDITOR=/usr/bin/vim

if [ -f /opt/local/etc/bash_completion ]; then
    . /opt/local/etc/bash_completion
fi

if [[ -s "$DOTFILES/bash/git-completion.bash" ]] ; then source "$DOTFILES/bash/git-completion.bash" ; fi

if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  if [[ "$(which rvm)" != "" ]]; then
    rvm reload
  else
    source "$HOME/.rvm/scripts/rvm"
    rvm use default
  fi
fi

platform='unknown'
if [[ "${OSTYPE:0:5}" == 'linux' ]]; then
  platform='linux'
elif [[ "${OSTYPE:0:6}" == 'darwin' ]]; then
  platform='darwin'
fi

if [[ "$platform" == "darwin" ]]; then
  export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home

  alias ls='ls -G'
else
  alias ls='ls --color'
fi
alias reload="source $HOME/.bash_profile"
alias e='exit'
alias less='less -R'
alias mysqlsrv="sudo /Library/StartupItems/MySQLCOM/MySQLCOM"
alias synergyd.stop='launchctl list  | grep synergyd | awk '\''{print $3}'\'' | xargs launchctl stop'

###############################
# tmux
###############################

# Generate tmux configs that are dependent on the capabilities of the parent shell
local_tmux_conf="$HOME/.tmux.conf.parent"
if [ "$(tput colors)" == "256" ]; then
  cat <<EOS > $local_tmux_conf
set-option -g default-terminal screen-256color
EOS
else
  echo "" > $local_tmux_conf
fi

if [ "$TMUX" != "" ]; then
  bind -x '"\C-l":clear && tmux clear-history'
fi

####################################
# Source configs that must be last
####################################
source $DOTFILES/bash/local.bash
