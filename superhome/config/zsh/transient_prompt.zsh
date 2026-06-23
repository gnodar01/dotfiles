# https://gist.github.com/subnut/3af65306fbecd35fe2dda81f59acf2b2
# https://github.com/olets/zsh-transient-prompt
# (with edits)

# minimal sanity check, /dev/null exists and is character device
[[ -c /dev/null ]]  ||  return
# load zsh/system module, needed for low-level sysopen
zmodload zsh/system ||  return

# dynamic prompt for transient display
# single quote preserves the $(...) so it evaluates each time prompt is displayed
TRANSIENT_PROMPT='$(starship prompt --profile transient --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="$STARSHIP_CMD_STATUS" --pipestatus="${STARSHIP_PIPE_STATUS[*]}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'

# kitty (and other OSC 133 terminals) inject a "prompt start" mark at the front
# of PS1 via shell integration. That mark is how the terminal delimits each
# command's output (used by `kitty @ get-text --extent last_cmd_output`, i.e.
# kitty-scrollback.nvim's kitty_mod+g). Replacing the finished command's prompt
# with the raw starship transient prompt drops the mark, so kitty can no longer
# tell where one command's output ends and the next begins and merges them.
# Re-add the zero-width mark (%{...%}) so transient prompts stay delimited.
if [[ -n $KITTY_SHELL_INTEGRATION ]]; then
  # KITTY_SHELL_INTEGRATION used as guard described here: https://sw.kovidgoyal.net/kitty/shell-integration/#shell-integration
  # %{ ... }% - tells zsh that enclosed bytes are zero width, so prompt alignment isn't affected
  # \e]133;A\a - standard prompt-mark start (\a is standard terminator kitty accepts to avoid backslash-escaping ESC \)
  # Only ;A needed here. ;C (output start) and ;D (command done) marks emitted by kitty's own preexec/precmd hooks, not from $PROMPT, so transient redraw shouldn't touch them.
  #   more info: https://sw.kovidgoyal.net/kitty/shell-integration/#notes-for-shell-developers
  TRANSIENT_PROMPT=$'%{\e]133;A\a%}'"$TRANSIENT_PROMPT"
fi

# dynamic prompt for normal display
function _set_prompt_normal {
  # single quote preserves the $(...) so it evaluates each time prompt is displayed
  # $COLUMNS: terminal width
  # $KEYMAP: current keymap (optional)
  # $STARSHIP_CMD_STATUS: last command exit code
  # $STARSHIP_PIPE_STATUS[*]: exit codes of piped commands
  # $STARSHIP_DURATION: last command duration
  # $STARSHIP_JOBS_COUNT: background jobs count
  PROMPT='$(starship prompt --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="$STARSHIP_CMD_STATUS" --pipestatus="${STARSHIP_PIPE_STATUS[*]}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
  RPROMPT='$(starship prompt --right --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="$STARSHIP_CMD_STATUS" --pipestatus="${STARSHIP_PIPE_STATUS[*]}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
}
# dynamic prompt for normal display, while preserving modifications to `PS1`
function _set_prompt_normal_preserve_ps {
  # sometime programs start a new shell, and modify `PS1` to show they did so
  #
  # e.g. `pixi shell`, `devbox shell`, `source venv/bin/activate`, etc.
  # for instance, in CellProfiler, running `pixi shell-hook -e dev` has this as the last line:
  # `export PS1="(CellProfiler:dev) ${PS1:-}"`
  #
  # this preserves such changes, while still injecting the dynamic prompt we want

  # the glob `\$\(*starship*\)` matches `$(/usr/local/bin/starship ...)` or `$(starship ...)`
  if [[ $PS1 == *\$\(*starship*\)* ]]; then
    local ps_prefix
    # `%%pattern` removes the longest trailing match of the pattern, leaving the prefix
    ps_prefix="${PS1%%\$\(*starship*\)*}"
    # strip out newline from before
    # `//pattern/replacement` replaces `pattern` with `replacement`, in this case blank, so strip all newlines
    ps_prefix="${ps_prefix//$'\n'/}"
    # insert a literal newline manually (make sure `add_newline = false` in `starship.toml`)
    PROMPT=$'\n'"${ps_prefix}"'$(starship prompt --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="$STARSHIP_CMD_STATUS" --pipestatus="${STARSHIP_PIPE_STATUS[*]}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
    RPROMPT='$(starship prompt --right --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="$STARSHIP_CMD_STATUS" --pipestatus="${STARSHIP_PIPE_STATUS[*]}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
  else
    PROMPT="$PS1"
    RPROMPT=''
  fi
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
  #_set_prompt_normal
  _set_prompt_normal_preserve_ps
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
