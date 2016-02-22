#!/bin/bash -e

function find_next_ssh {
  local script_path=${BASH_SOURCE[1]}
  local ssh_commands=($(which -a ssh))
  local ssh_command=""

  for (( i=0; i < ${#ssh_commands[@]}; i=$i+1 )); do
    if [[ "${ssh_commands[$i]}" == $script_path ]]; then
      break
    fi
  done

  if [[ $((i+1)) -eq ${#ssh_commands[@]} ]]; then
    echo "Could not find an ssh command other than this one ($script_path); exiting" 1>&2
    return 1
  fi

  # ignore relative paths in PATH, since they don't make sense in the context of
  # nested command-wrapping
  for (( i=$((i+1)); i < ${#ssh_commands[@]}; i=$i+1 )); do
    ssh_command="${ssh_commands[$i]}"
    if [[ "${ssh_command:0:2}" != "./" ]]; then
      break
    fi
  done

  if [[ $i -eq ${#ssh_commands[@]} ]]; then
    echo "Could not find an ssh command; exiting" 1>&2
    return 1
  fi

  echo "$ssh_command"
  return 0
}

