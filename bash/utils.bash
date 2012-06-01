# Decorates a pre-existing function or builtin with additional behavior. The decoration
# is achieved by defining a '<command>_without_<feature>' method, where '<command>'
# is a pre-existing command, and '<feature>' identifies and describes the behavior
# being added.
#
# This approach was inspired by the 'alias_method_chain' method in Ruby on Rails.
#
# Sample:
#   cd_with_listing() {
#     cd_without_listing $@
#     ls
#   }
#   decorate_function 'cd' 'listing'
#
# The above command will create a method called cd_without_listing that does what the
# original definition of 'cd' did; it then re-defines 'cd' to invoke 'cd_with_listing'.
decorate_function() {
  local func=$1
  local feature=$2
  local undecorated_func_name=$func"_without_"$feature

  if [ "$(type -t $undecorated_func_name)" == "function" ]; then
    echo "already decorated $func with $feature"
    return 1
  fi

  local command_type=$(type -t $func)
  if [ "$command_type" == "function" ]; then
    local prev_declaration="$(declare -f $func)"
    eval "$(echo "$undecorated_func_name()" ; echo "$prev_declaration" | tail -n +2)"
  elif [ "$command_type" == "builtin" ]; then
    eval $undecorated_func_name'() {
      builtin '$func' "$@"
    }'
  else
    echo "unrecognized type of original $func: $command_type"
    return 1
  fi

  local decorated_func_name=$func"_with_"$feature
  eval $func'() {
    '$decorated_func_name' "$@"
  }'
}

