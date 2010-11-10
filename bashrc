#!/bin/sh
if [ "$ORIGINAL_PATH" = "" ]; then
   export ORIGINAL_PATH=$PATH
fi

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
PS1="\h:\u \W\$(parse_git_branch)\$ "

PATH=$ORIGINAL_PATH
export PATH=$HOME/bin:$DOTFILES/bin:$HOME/bin/wireshark:$HOME/bin/flex/bin:/usr/local/texlive/2008/bin/universal-darwin:/opt/local/bin:/usr/local/mysql/bin:$HOME/.gem/ruby/1.8/bin:$ORIGINAL_PATH
export MANPATH=/opt/local/man:$MANPATH
export EDITOR=/usr/bin/vim
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home

if [ -f /opt/local/etc/bash_completion ]; then
    . /opt/local/etc/bash_completion
fi

if [[ -s "$DOTFILES/bash/git-completion.bash" ]] ; then source "$DOTFILES/bash/git-completion.bash" ; fi

if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  source "$HOME/.rvm/scripts/rvm"
  rvm default
fi

platform='unknown'
if [[ "${OSTYPE:0:5}" == 'linux' ]]; then
  platform='linux'
elif [[ "${OSTYPE:0:6}" == 'darwin' ]]; then
  platform='darwin'
fi

if [[ "$platform" == "darwin" ]]; then
  alias ls='ls -G'
else
  alias ls='ls --color'
fi
alias reload="source $HOME/.bash_profile"
alias e='exit'
alias mysqlstart.rails="sudo mysqld_safe --defaults-file=$DOTFILES/my.cnf.rails 2>&1 > /dev/null &"
alias mysqlstop="sudo killall mysqld"

in_login_shell() {
  if [[ "$(shopt login_shell)" =~ "off" ]]; then echo 1; else echo 0; fi
}