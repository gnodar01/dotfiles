# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/jump/jump.plugin.zsh

# Easily jump around the file system by manually adding marks
# marks are stored as symbolic links in the directory $MARKPATH (default $HOME/.marks)
#
# jump FOO: jump to a mark named FOO
# mark FOO: create a mark named FOO
# unmark FOO: delete a mark
# marks: lists all marks
#
export MARKPATH=$HOME/.marks

function jump() {
	local markpath="$(readlink $MARKPATH/$1)" || {echo "No such mark: $1"; return 1}
	builtin cd "$markpath" 2>/dev/null || {echo "Destination does not exist for mark [$1]: $markpath"; return 2}
}
alias jp=jump

function mark() {
	if [[ $# -eq 0 || "$1" = "." ]]; then
		MARK=${PWD:t}
	else
		MARK="$1"
	fi
	if read -q "?Mark $PWD as ${MARK}? (y/n) "; then
		command mkdir -p "$MARKPATH"
		command ln -sfn "$PWD" "$MARKPATH/$MARK"
	fi
}

function unmark() {
	LANG= command rm -i "$MARKPATH/$1"
}

function marks() {
	#local link max=0
	#for link in $MARKPATH/{,.}*(@N); do
	#	if [[ ${#link:t} -gt $max ]]; then
	#		max=${#link:t}
	#	fi
	#done
	#local printf_markname_template="$(printf -- "%%%us" "$max")"
	#for link in $MARKPATH/{,.}*(@N); do
	#	local markname="$fg[cyan]$(printf -- "$printf_markname_template" "${link:t}")$reset_color"
	#	local markpath="$fg[blue]$(readlink $link)$reset_color"
	#	printf -- "%s -> %s\n" "$markname" "$markpath"
	#done
  eza --oneline --all --classify=auto $MARKPATH
}

function _completemarks() {
  local -a marks
	marks=("${MARKPATH}"/{,.}*(@N:t))
  compadd "$@" -- "${marks[@]}"
}

zle -N _mark_expansion
function _mark_expansion() {
	setopt localoptions extendedglob
	autoload -U modify-current-argument
	modify-current-argument '$(readlink "$MARKPATH/$ARG" || echo "$ARG")'
}

# jump back
function jumpb () {
  builtin cd "$OLDPWD" 2> /dev/null || {
    echo "Desintation does not exist: \"$OLDPWD\""
    return 2
  }
}

# fuzzy jump
function fj () {
  local query="$1"
  local candidate
  candidate=$(ls -A "$MARKPATH" | fzf --query "$query" -1)

  if [ -z "$candidate" ]; then
    echo "Cannot resolve mark: $query"
    return 1
  fi

  local markpath
  if ! markpath=$(readlink "$MARKPATH/$candidate"); then
    echo "No such link: $query -> $candidate"
    return 1
  fi

  if ! builtin cd "$markpath" 2>/dev/null; then
    echo "Destination does not exist for mark [$query -> $candidate]: $markpath"
    return 2
  fi
}

zle -N _fuzzy_mark_expansion
function _fuzzy_mark_expansion() {
	setopt localoptions extendedglob
  autoload -U modify-current-argument
  modify-current-argument '$(readlink "$MARKPATH/$(ls -A $MARKPATH | fzf --query=$ARG -1)" || echo "$ARG")'
}
