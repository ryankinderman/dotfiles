#!/bin/bash
# Note: This has to be sourced at the end of other scripts, since re-defining
# 'cd' commands is common, and we want to be sure that we define bash_local
# behavior last, since it does the right thing about retaining pre-existing
# overrides for those commands (like from rvm).

define_cd_with_bash_local() {
  local cmd=$1
  local decorated_func_name=$cmd'_with_bash_local'

  eval $decorated_func_name'() {
    export __rdk_bash_local_lock
    : __rdk_bash_local_lock:${__rdk_bash_local_lock:=0}
    : __rdk_bash_local_lock:$((__rdk_bash_local_lock+=1))
    local lock=$__rdk_bash_local_lock

    '$cmd'_without_bash_local "$@"

    local exit_val=$?
    [[ $exit_val != 0 ]] && return $exit_val

    (( lock > 1 )) && return 0 # no nesting

    local filename=.bash_local
    local script=${BASH_SOURCE[0]}

    if [[ (-f $filename) ]]; then
      if [[ "$(grep $PWD $HOME/$filename.allowed > /dev/null 2>&1 ; echo $?)" == "0" ]]; then
        source $filename
        echo "Sourced $filename"
      else
        cat <<STR
===============================================================================
From: $script
-------------------------------------------------------------------------------
$filename is present in the current directory, but not in the list of
allowed directories to auto-source from. For security, a directory must be
in the list of allowed directories before it'\''s auto-sourced. To add the
current directory to the list of allowed directories, run:

echo "$PWD" >> $HOME/$filename.allowed
===============================================================================
STR
      fi
    fi

    unset __rdk_bash_local_lock
  }'
  decorate_function "$cmd" "bash_local"
}

for cmd in cd popd pushd; do
  define_cd_with_bash_local $cmd
done
