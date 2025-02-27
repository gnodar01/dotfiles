# profiling: https://stevenvanbael.com/profiling-zsh-startup
# put this as the beginning of ~/.zshrc
#zmodload zsh/zprof
# put this at the end of ~/.zshrc
#zprof

export SUPERHOME=$HOME/superhome
PATH="$SUPERHOME/bin:$PATH"

# poetry, virtualenv, and others
PATH="$HOME/.local/bin:$PATH"

# when doing rm folder/* or `rm *` zsh asks "sure you want to delete all the files in ... [yn]?"
# even if -f set
# this disables that
# https://unix.stackexchange.com/questions/135084/double-rm-verification-in-zsh
setopt rm_star_silent

# https://superuser.com/questions/1563825/is-there-a-zsh-equivalent-to-the-bash-help-builtin
if [[ "$(whence -w run-help | cut -d : -f 2 | tr -d ' ')" == "alias" ]]; then
    unalias run-help
fi
autoload run-help
HELPDIR=/usr/share/zsh/"${ZSH_VERSION}"/help
alias help=run-help

alias rm="rm -iv"
alias mv="mv -iv"
alias cp="cp -riv"
alias mkdir="mkdir -vp"

alias diffc="diff --color=always"
alias lessc="less -r"
alias subl="sublime_text"

#alias myip="curl http://ipecho.net/plain; echo"
alias myip="curl -s https://ipv4.icanhazip.com/"
alias myip6="curl -s https://ipv6.icanhazip.com/"
alias myipp="utilhelpers myip"
# show all env variables - must be alias not function
alias envv="( setopt posixbuiltin; set; ) | less"
alias dostat="utilhelpers dostat"

alias pltoxml="utilhelpers pltoxml"
alias xmltopl="utilhelpers xmltopl"
# https://fgimian.github.io/blog/2015/06/27/a-simple-plistbuddy-tutorial/
alias plistbuddy="/usr/libexec/PlistBuddy"

# syntax highlight man pages with bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# use eza instead of ls
alias l="eza --all --icons=auto --classify=auto"
alias ll="eza --long --all --git --header --icons=auto --classify=auto"
alias t="eza --oneline --all --icons=auto --classify=auto"
alias tt="eza --tree --all --classify=auto --icons=auto --level=2"
alias ttt="eza --tree --all --classify=auto --icons=auto --level=3"
alias tttt="eza --tree --all --classify=auto --icons=auto --level=4"

alias cdd="cd ~/Desktop"

# https://github.com/rptb1/aliasPath
# found from here:
# https://stackoverflow.com/questions/1175094/os-x-terminal-command-to-resolve-path-of-an-alias### cd into alias folder ###
# clone, compile with `sudo xcodebuild install`, which creates `/usr/local/bin/aliasPath`
# move to $HOME/bin
export cdBack=""
cda() {
  if [[ -f "$1" || -L "$1" ]]; then
    cdBack="$(pwd)"
    truePath="$(aliasPath "$1")"
    builtin cd "$truePath"
  else
    builtin cd "$@"
  fi
}

cdb() {
  if [[ -n "$cdBack" ]]; then
    builtin cd "$cdBack"
  else
    echo "cd back not set"
  fi
}
### /cd into alias folder ###

alias hex="hexyl"

shellfancyinits() {
  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

  # this is for the zsh-vi-mode plugin I use with oh-my-zsh
  # this test idiom from: https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
  if [ -z ${ZVM_CONFIG_FUNC+x} ]
  # if $SUPERHOME/config/oh-my-zsh/.oh-my-zsh was NOT sourced before sourcing this file
  # or if zsh-vi-mode there was NOT enabled
  # then load fzf directly
  then
      # fzf - enable auto completing and key bindings
      source <(fzf --zsh)
  else
      # else oh-my-zsh loaded with zsh-vi-mode
      # which would normally override key bindings from other places
      # we re-enable fzf keybindings using bellow, by wrapping it in a zsh-vi-mode hook
      # https://github.com/jeffreytse/zsh-vi-mode?tab=readme-ov-file#execute-extra-commands
      zvm_after_init_commands+=('source <(fzf --zsh)')
  fi
}
## late key bindings
# runs right before you start typing at the prompt
_late_bindings() {
  # omz "jump" plugin - expand mark to full path
  bindkey "^G" _mark_expansion
}
autoload -Uz add-zle-hook-widget
add-zle-hook-widget zle-line-init _late_bindings
## / late key bindings

# -m flag for multi-select, TAB/SHIFT-TAB to mark items
export FZF_DEFAULT_OPS="-m"
#export FZF_COMPLETION_OPTS='--border --info=inline'
# ignore node_modules and .git
# https://stackoverflow.com/questions/61865932/how-to-get-fzf-vim-ignore-node-modules-and-git-folders
export FZF_DEFAULT_COMMAND='find . \( -name node_modules -o -name .git \) -prune -o -print'

# basic preview with bat
alias fzfpreview="utilhelpers fzfpreview"
# use opener; takes opt arg; depth 1
alias fzfp="utilhelpers fzfp"
# use opener; no arg; inf depth
alias fzfpp="utilhelpers fzfpp"
# use opener; no arg; inf depth; pipe res into ll
alias fzfppls="utilhelpers fzfppls"

alias npmglobals="utilhelpers npmglobals"

alias pypi="utilhelpers pypi"
alias pipcompat="utilhelpers pipcompat"

alias dockersize="utilhelpers dockersize"

alias nv="nvim"

# set neovim as main editor
export EDITOR="nvim"

alias ca="conda activate"
alias cx="conda deactivate"
function ce(){
    conda activate $(conda env list | tail -n+3 | awk '{print $1}' | fzf)
}

# NOTE: just use pgrep instead
# leaving here until you remember
alias psa="ps -A | grep -v grep"

alias pycolors="pycolors.py"
alias pyfansi="pyfansi.py"
alias pycodepoints="pycodepoints.py"

# python
# set this in case you want sys.path to include some custom path to a package
# note: also check path/to/site-packages/easy-install.pth for things that `pip install -e` puts into sys.path
#       it's possible to add a custom *.pth file which will also be parsed
# export PYTHONPATH=""

yadmc() {
  # Check if yadm is installed
  if ! command -v yadm &>/dev/null; then
    echo "Error: yadm is not installed or not in PATH." >&2
    return 1
  fi

  yadm status

  # Ensure a commit message is provided
  if [[ -z "$1" ]]; then
    echo "Usage: ydm <commit-message> [nop]"
    echo "  commit-message: The message for the commit."
    echo "  nop (optional): If provided, prevents 'yadm push'."
    return 1
  fi

  # Add and commit changes
  yadm add -u
  yadm commit -m "$1"

  # Push unless 'nop' is passed
  if [[ "$2" != "nop" ]]; then
    yadm push
  fi

  yadm status
}

## NVM and node
#
# lazy load nvm - p10k instant prompt is not enough
lazy_load_nvm() {
  unset -f nvm npm npx node yarn pnpm
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}
#
nvm() {
  lazy_load_nvm
  nvm $@
}
#
npm() {
  lazy_load_nvm
  npm $@
}
#
npx() {
  lazy_load_nvm
  npx $@
}
#
node() {
  lazy_load_nvm
  node $@
}
#
yarn() {
  lazy_load_nvm
  yarn $@
}
#
pnpm() {
  lazy_load_nvm
  pnpm $@
}
#
pnpx() {
  lazy_load_nvm
  pnpx $@
}
#
## / NVM and node

