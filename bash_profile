#!/bin/sh
if [ "$ORIGINAL_PATH" = "" ]; then
   export ORIGINAL_PATH=$PATH
fi

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
PS1="\h:\u \W\$(parse_git_branch)\$ "

PATH=$ORIGINAL_PATH
export PATH=$HOME/bin:$HOME/bin/wireshark:$HOME/bin/flex/bin:/usr/local/texlive/2008/bin/universal-darwin:/opt/local/bin:/usr/local/mysql/bin:$HOME/.gem/ruby/1.8/bin:$ORIGINAL_PATH
export MANPATH=/opt/local/man:$MANPATH
export EDITOR=/usr/bin/vim
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home

if [ -f /opt/local/etc/bash_completion ]; then
    . /opt/local/etc/bash_completion
fi
if [[ -s "$HOME/.rvm/scripts/rvm" ]]  ; then source "$HOME/.rvm/scripts/rvm" ; fi

alias ls='ls -G'
alias reload="source $HOME/.bash_profile"
alias e='exit'
alias mysqlstart.rails="sudo mysqld_safe --defaults-file=$DOTFILES/my.cnf.rails 2>&1 > /dev/null &"
alias mysqlstop="sudo killall mysqld"

source $DOTFILES/mmh_env
