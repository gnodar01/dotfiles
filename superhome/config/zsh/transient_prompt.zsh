#!/bin/zsh

# minimal sanity check, /dev/null exists and is character device
[[ -c /dev/null ]]  ||  return
# load zsh/system module, needed for low-level sysopen
zmodload zsh/system ||  return

# dynamic prompt for transient display
# single quote preserves the $(...) so it evaluates each time prompt is displayed
TRANSIENT_PROMPT='$(STARSHIP_CONFIG=$SUPERHOME/config/starship/transient.toml starship prompt --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="$STARSHIP_CMD_STATUS" --pipestatus="${STARSHIP_PIPE_STATUS[*]}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'

function _set_prompt_normal {
  # dynamic prompt for normal display
  # single quote preserves the $(...) so it evaluates each time prompt is displayed
  # $COLUMNS: terminal width
  # $KEYMAP: current keymap (optional)
  # $STARSHIP_CMD_STATUS: last command exit code
  # $STARSHIP_PIPE_STATUS[*]: exit codes of piped commands
  # $STARSHIP_DURATION: last command duration
  # $STARSHIP_JOBS_COUNT: background jobs count
  PROMPT='$(starship prompt --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="$STARSHIP_CMD_STATUS" --pipestatus="${STARSHIP_PIPE_STATUS[*]}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
  RPROMPT=''
}

# rebind (extend) Zsh line editor widget, `send-break`
zle -N send-break _transient_prompt-send-break
function _transient_prompt-send-break {
  # finalize transient prompt
  _transient_prompt-zle-line-finish
  # do native `send-break`
  zle .send-break
}

# rebind (overwrite) Zsh line editor widget, `zle-line-finish`, which runs when command line finishes
zle -N zle-line-finish _transient_prompt-zle-line-finish
# sets the transient prompt
function _transient_prompt-zle-line-finish {
  # if `_transient_prompt_fd` is not set, or is `0`
  (( ! _transient_prompt_fd )) && {
    # open `/dev/null` as file descriptor (FD), assigning to `_transient_prompt_fd`
    # `-r` is read-only
    # `-o cloexec` ensures the FD is auto-closed if an `exec`-type program is run
    # `-u <var>` assignes the opened FD number to `<var>`
    sysopen -r -o cloexec -u _transient_prompt_fd /dev/null
    # register file descriptor watch event with ZLE
    # to call `_transient_prompt-restore-prompt` when fd is ready (readable)
    # async, so this func (`_transient_prompt-zle-line-finish`)
    # will finish first, then `_transient_prompt-restore-prompt` runs
    zle -F $_transient_prompt_fd _transient_prompt-restore-prompt
  }
  # if inside ZLE (interactive editing mode), then
  # set PROMPT to transient, RPROMPT to nothing
  # reset prompt, refresh display
  zle && PROMPT=$TRANSIENT_PROMPT RPROMPT= zle reset-prompt && zle -R
}

# callback - restores the normal prompt after transient prompt is displayed
function _transient_prompt-restore-prompt {
  # close file descriptor 1 (stdout) in current shell
  # `{1}` is zsh dynamic FD syntax, but here equiv to just `1`
  # `>` is redirect, `&-` means close fd
  # `exec` to do in current shell
  # this triggers auto close of the FD ($1) asscoiated with /dev/null
  exec {1}>&-
  # if argument, unregister previous handler for FD from ZLE
  (( ${+1} )) && zle -F $1
  # resets `_transient_prompt_fd`
  _transient_prompt_fd=0
  # set the normal prompt
  _set_prompt_normal
  # reset prompt
  zle reset-prompt
  # refresh display
  zle -R
}

# if `precmd_functions` (called before each command) does not exist 
# define it, make it a global variable (`-g`), make it an array (`-a`)
(( ${+precmd_functions} )) || typeset -ga precmd_functions
# if `precmd_functions` array is empty, initialize it and give it some noop
(( ${#precmd_functions} )) || {
  do_nothing() {true}
  precmd_functions=(do_nothing)
}

# add SIGINT trap to precmds
precmd_functions+=_transient_prompt-precmd
# define custom TRAPINT function (runs on Ctrl+C/interrupt)
# updates the transient prompt before exiting command
# returns proper exit code for SIGINT (128 + <signal number>)
function _transient_prompt-precmd {
  TRAPINT() { zle && _transient_prompt-zle-line-finish; return $(( 128 + $1 )) }
}
