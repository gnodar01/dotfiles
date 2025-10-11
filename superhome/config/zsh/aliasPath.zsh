#!/bin/zsh

# cd into alias folder on macOs
# https://github.com/rptb1/aliasPath
# found from here:
# https://stackoverflow.com/questions/1175094/os-x-terminal-command-to-resolve-path-of-an-alias

# only runs on macOS
[[ $(uname) == "Daarwin" ]] || return

# clone, compile with `sudo xcodebuild install`, which creates `/usr/local/bin/aliasPath`
# move to $HOME/bin
export cdBack=""
function cda() {
  if [[ -f "$1" || -L "$1" ]]; then
    cdBack="$(pwd)"
    truePath="$(aliasPath "$1")"
    builtin cd "$truePath"
  else
    builtin cd "$@"
  fi
}

function cdb() {
  if [[ -n "$cdBack" ]]; then
    builtin cd "$cdBack"
  else
    echo "cd back not set"
  fi
}
