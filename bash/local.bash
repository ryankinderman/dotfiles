#!/bin/bash
###############################
# Description
###############################
#
# Automatically source a .bash_local file when changing into a directory that
# has one.
#
# Note: This has to be sourced at the end of other scripts, since re-defining
# 'cd' commands is common, and we want to be sure that we define bash_local
# behavior last, since it does the right thing about retaining pre-existing
# wrappers of those commands (like from rvm).
#
#
###############################
# Writing .bash_local files
###############################
#
# You can write a .bash_local file like you would any other bash script, with
# the following differences:
#
# Environment variables:
# * rdk_bash_local_nesting
#   The level of nesting of change directory commands. Since bash_local wraps
#   the commands that change an environment's current directory, it's possible
#   for other wrappers of those commands to change directory before sourcing
#   the .bash_local file, or while sourcing the .bash_local file. Each
#   execution of a directory-changing command will increase the value of
#   rdk_bash_local_nesting, allowing .bash_local files to determine the level
#   of nesting. The initial value is 1. This is useful for ensuring that
#   some parts of a .bash_local script are executed only once. Example:
#
#   # .bash_local in /some/directory
#   echo "Executed every time the environment changes into /some/directory while sourcing this file"
#   (( $rdk_bash_local_nesting != 1 )) && return 0
#   echo "Only executed on the first directory-changing command into /some/directory"
#
#
###############################
# Todo:
###############################
#
# * Support sourcing .bash_local from parent directories if any exist when
#   changing into a child directory (like rvmrc)

define_cd_with_bash_local() {
  local cmd=$1
  local decorated_func_name=$cmd'_with_bash_local'

  eval $decorated_func_name'() {
    # protect against double-sourcing for bash_local in the same shell
    export __rdk_bash_local_nesting_export
    : __rdk_bash_local_nesting_export:${__rdk_bash_local_nesting_export:=0}
    : __rdk_bash_local_nesting_export:$((__rdk_bash_local_nesting_export+=1))
    local rdk_bash_local_nesting=$__rdk_bash_local_nesting_export

    if '$cmd'_without_bash_local "$@"; then
      local filename=.bash_local
      local script=${BASH_SOURCE[0]}

      if [[ (-f $filename) ]]; then
        if [[ "$(grep $PWD $HOME/$filename.allowed > /dev/null 2>&1 ; echo $?)" == "0" ]]; then
          local pwd=$PWD
          source $filename
          echo "Sourced $filename in $pwd"
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
    fi

    if (( $rdk_bash_local_nesting == 1 )); then
      unset __rdk_bash_local_nesting_export
    fi
  }'
  decorate_function "$cmd" "bash_local"
}

for cmd in cd popd pushd; do
  define_cd_with_bash_local $cmd
done
