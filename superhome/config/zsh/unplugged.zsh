#!/bin/zsh

# https://github.com/mattmc3/zsh_unplugged
export ZPLUGINDIR="$HOME/.config/zsh/plugins"
# Clone a plugin, identify its init file, source it, and add it to your fpath.
function plugin-load {
  local plugin repo commitsha plugdir initfile initfiles=()
  # set default plugin directory if not already set
  # `:` is a no-op used to trigger parameter expansion
  # `:=` paramater expansion with assignment - assigns if not already assigned
  # `:-` default value substitution - evaluate (not assign) lhs if set else rhs
  : ${ZPLUGINDIR:=${ZDOTDIR:-$HOME/.config/zsh}/plugins}

  # for each plugin-repo
  for plugin in $@; do
    repo="$plugin"
    clone_args=(-q --depth 1 --recursive --shallow-submodules)

    # check if plugin pinned to specific commit (format: user/repo@commitsha)
    if [[ "$plugin" == *'@'* ]]; then
      repo="${plugin%@*}"         # extract repo before commit
      commitsha="${plugin#*@}"    # extract commit SHA
      clone_args+=(--no-checkout) # delay checkout to later after fetching specific commit
    fi

    # determine plugin installation dir and expected init file
    # `:` acts as zsh filename transformation
    # `t` stands for tail, extracting last component of a path
    # `repo:t` extracts "myplugin" from "user/myplugin"
    plugdir=$ZPLUGINDIR/${repo:t}          # dir named after plugin
    initfile=$plugdir/${repo:t}.plugin.zsh # standard init path

    # clone plugin repo only if not already installed
    if [[ ! -d $plugdir ]]; then
      echo "Cloning ZSH plugin: $repo..."
      git clone "${clone_args[@]}" https://github.com/$repo $plugdir

      # if commit sha specified (user/repo@commitsha), fetch and checkout that commit
      if [[ -n "$commitsha" ]]; then
        git -C $plugdir fetch -q origin "$commitsha"
        git -C $plugdir checkout -q "$commitsha"
      fi
    fi

    # if init file does not exist, find one in the plugin directory
    if [[ ! -e $initfile ]]; then
      # `initfiles` is an array
      # `(N)` is Nullglob - if glob matches nothing, expand to nothing instead of literal pattern
      # preventing error if/when no files match
      initfiles=($plugdir/*.{plugin.zsh,zsh-theme,zsh,sh}(N))
      # if no candidate for init file, say so and go to next plugin
      (( $#initfiles )) || { echo >&2 "No init file found '$repo'." && continue }
      # if one or more candidates found, symlink the first matching one
      ln -sf $initfiles[1] $initfile
    fi

    # add plugin directory to fpath for function autoloading
    fpath+=$plugdir

    # source init file, using zsh-defer if available for deferred loading
    # `$+functions[name]` 1 if function exists else 0
    # `(( ... ))` is arithmetic evaluation
    (( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
  done
}
