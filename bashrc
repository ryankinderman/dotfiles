#!/bin/bash -e
########################################################################
# To properly integrate with dotfiles, add this to the top of your
# $HOME/.bashrc:
#
#   source $DOTFILES/bashrc
#
# Then, place any machine-specific non-login settings in $HOME/.bashrc.
########################################################################

if [ -z "${DOTFILES+x}" ]; then
  echo "${BASH_SOURCE[0]}: The DOTFILES environment variable must be defined before sourcing this file." 2>&1
  return
fi

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

SHELL_CMD=${SHELL##*/}

if [[ $SHELL_CMD == "bash" ]]; then
  PS1="\h:\u \W\$(parse_git_branch)\$ "
fi

if [ -z "${DOTFILES_PATHS_SOURCED}" ]; then
  echo "Warning: \$DOTFILES/pathrc not sourced. Source this file from your non-login shell init file, e.g. \$HOME/.bashrc or \$HOME/.zshrc." 1>&2
fi

if [[ $(uname) == "Darwin" ]]; then
  if [[ $(uname -m) == "arm64" ]]; then
    if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
      export PATH=/opt/homebrew/opt/ruby/bin:$PATH
      export PATH=`gem environment gemdir`/bin:$PATH
    fi
  else
    if [ -d "/usr/local/opt/ruby/bin" ]; then
      export PATH=/usr/local/opt/ruby/bin:$PATH
      export PATH=`gem environment gemdir`/bin:$PATH
    fi
  fi
fi

export PATH=$DOTFILES/bin:$PATH

export EDITOR=vim

### begin
# Define XDG variables, used by git and other tools
# See https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html for details
export XDG_CONFIG_HOME=$HOME/.config
### end

if [[ $SHELL_CMD == "bash" ]]; then
  if [ -f /opt/local/etc/bash_completion ]; then
    . /opt/local/etc/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Prevent escaping $ when tab-completing paths for the `ls` command that
# include env vars. Without this, typing the following:
#     $GEM_HOME/g<TAB>
# ... results in:
#     \$GEM_HOME/gems
#
# Note: This needs to be after sourcing bash completion, which sets the
# problematic completion
if [[ $SHELL_CMD == "bash" ]]; then
  complete -r ls ln
  complete -D -r ls ln
fi


if [[ $SHELL_CMD == "bash" ]] && [[ -s "$DOTFILES/bash/git-completion.bash" ]] ; then source "$DOTFILES/bash/git-completion.bash" ; fi

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
alias dc="docker-compose"
alias reload="source $HOME/.bash_profile"
alias vim="vim -u $HOME/.vimrc" # needed so that a global vimrc file doesn't mess with config loading
alias e='exit'
alias less='less -R'
alias pse='ps -ewwo user,pid,ppid,%cpu,%mem,vsz,rss,tty,stat,start,time,command'
alias mysqlsrv="sudo /Library/StartupItems/MySQLCOM/MySQLCOM"
alias synergyd.stop='launchctl list  | grep synergyd | awk '\''{print $3}'\'' | xargs launchctl stop'

###############################
# Terminal color support
###############################

if [ "$TERM" = "xterm" ] ; then
  if [ -z "$COLORTERM" ] ; then
    if [ -z "$XTERM_VERSION" ] ; then
      echo "Warning: Terminal wrongly calling itself 'xterm'."
    else
      case "$XTERM_VERSION" in
        "XTerm(256)" | "XTerm(278)") TERM="xterm-256color" ;;
        "XTerm(88)") TERM="xterm-88color" ;;
        "XTerm") ;;
        *)
            echo "Warning: Unrecognized XTERM_VERSION: $XTERM_VERSION"
            ;;
      esac
    fi
  else
    case "$COLORTERM" in
      gnome-terminal|Terminal|xfce4-terminal)
        TERM="xterm-256color" ;;
      *)
        echo "Warning: Unrecognized COLORTERM: $COLORTERM" ;;
    esac
  fi
fi


###############################
# tmux
###############################

# Generate tmux configs that are dependent on the capabilities of the parent shell
local_tmux_conf="$HOME/.tmux.conf.parent"
if [[ "$(tput colors)" == "256" ]]; then
  cat <<EOS > $local_tmux_conf
set-option -g default-terminal screen-256color
EOS
else
  echo "" > $local_tmux_conf
fi

if [[ "$TMUX" != "" ]]; then
  if [[ $SHELL_CMD == "bash" ]]; then
    bind -x '"\C-l":clear && tmux clear-history'
  fi
fi

####################################
# Source configs that must be last
####################################
if [[ $SHELL_CMD == "bash" ]]; then
  source $DOTFILES/bash/local.bash
fi

# Indicate that the base environment has been successfully loaded, so dependencies can check for it
export DOTFILES_BASH_LOADED=true
