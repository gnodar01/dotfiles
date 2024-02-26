#!/bin/bash

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

text_editor='nvim'

# ------------------------------------
# Environment variables
# ------------------------------------
export VISUAL=$text_editor
export EDITOR="$VISUAL"
export GIT_EDITOR="$VISUAL"

# ------------------------------------
# ALIASES
# ------------------------------------
# Aliases for (1) quickly opening .bashrc and (2) have terminal recognize changes to it
alias bashedit='sudo ${text_editor} ~/.bashrc'
alias bashrefresh='source ~/.bashrc'

alias bashappendedit='sudo ${text_editor} ~/.bashrc-append'
alias bashappendrefresh='source ~/.bashrc-append'

# Search history. Example usage: histg foo
alias histg="history | grep"

# -l list in long format
# -F Display a...
#       slash (`/') immediately after each pathname that is a directory,
#       asterisk (`*') after each that is executable,
#       at sign (`@') after each symbolic link
#       equals sign (`=') after each socket,
#       percent sign (`%') after each whiteout,
#       vertical bar (`|') after each that is a FIFO.
# -G = Color
# -a = Show hidden files
alias ll="ls -laFG"

# Ask before removing files
alias rm='rm -i'

# ------------------------------------
# Define color variables
# ------------------------------------

# Below are normal ANSI escape sequences but surrounded by \[ and \]
# 
# For the escape sequence:
#   \e is escape, a rare form of the ASCII hex `\x1B'
#   [ is the control sequence introducer (CSI)
#   <n1>;<n2>;... is a list of Select Graphic Rendition (SGR) parameters
#   m is the SGR terminator
#
# The surrounding \[ and \] is not a regular part of ANSI escape sequences
# (ie wouldn't be used with eg printf)
# but is needed for prompt control in bash (eg PS1, etc):
#   \[ begins a sequence of non-printing characters
#   \] ends a sequence of non-printing characters
# Othere special characters are used for prompt control:
#   \u username of the current user
#   \h hostname up to the first `.'
#   \w current working directory with $HOME abbreviated with a tilde
#
# For more info on prompt control do `man bash' and search for `PROMPTING'

# Regular Colors
Black='\[\e[0;30m\]'        # Black
Red='\[\e[0;31m\]'          # Red
Green='\[\e[0;32m\]'        # Green
Yellow='\[\e[0;33m\]'       # Yellow
Blue='\[\e[0;34m\]'         # Blue
Purple='\[\e[0;35m\]'       # Purple
Cyan='\[\e[0;36m\]'         # Cyan
White='\[\e[0;37m\]'        # White
Light_Gray='\[\033[0;37m\]'

# Bold
BBlack='\[\e[1;30m\]'       # Black
BRed='\[\e[1;31m\]'         # Red
BGreen='\[\e[1;32m\]'       # Green
BYellow='\[\e[1;33m\]'      # Yellow
BBlue='\[\e[1;34m\]'        # Blue
BPurple='\[\e[1;35m\]'      # Purple
BCyan='\[\e[1;36m\]'        # Cyan
BWhite='\[\e[1;37m\]'       # White
BLight_Gray='\[\033[1;37m\]'

# High Intensity
IBlack='\[\e[0;90m\]'       # Black
IRed='\[\e[0;91m\]'         # Red
IGreen='\[\e[0;92m\]'       # Green
IYellow='\[\e[0;93m\]'      # Yellow
IBlue='\[\e[0;94m\]'        # Blue
IPurple='\[\e[0;95m\]'      # Purple
ICyan='\[\e[0;96m\]'        # Cyan
IWhite='\[\e[0;97m\]'       # White

# Bold High Intensity
BIBlack='\[\e[1;90m\]'      # Black
BIRed='\[\e[1;91m\]'        # Red
BIGreen='\[\e[1;92m\]'      # Green
BIYellow='\[\e[1;93m\]'     # Yellow
BIBlue='\[\e[1;94m\]'       # Blue
BIPurple='\[\e[1;95m\]'     # Purple
BICyan='\[\e[1;96m\]'       # Cyan
BIWhite='\[\e[1;97m\]'      # White

# Reset colors
NONE="\[\e[0m\]"

# ------------------------------------
# Configure prompt
# Includes special handling for git repos
# ------------------------------------

# When in a git repo, this method is used to determine the current branch
function parse_git_branch {
    git branch 2>/dev/null | grep '^*' | sed 's_^..__' | sed 's_\(.*\)_(\1)_'
}

# When in a git repo, this method is used to determine if there are changes
function git_dirty {
    git diff --quiet HEAD &>/dev/null
    [ $? == 1 ] && echo "!"
}

# Variables
ps1_user="$BIBlue\u$NONE"
ps1_host="$IGreen\h$NONE"
ps1_dir="$BIPurple\w$NONE"
#ps1_git="$Cyan \$(parse_git_branch)$Red \$(git_dirty)$NONE"

# Option 1 user@host:dir(branch)! $
# export PS1="${ps1_user}@${ps1_host}:${ps1_dir}${ps1_git} \$ "

# Option 2 dir(branch)! $
export PS1="${ps1_dir}${ps1_git} \$ "

# ------------------------------------
# Load non-generic .bashrc
# To use, create ~/.bashrc-append
# This is where you might put aliases, functions, etc.
# that are specific to your system
# ------------------------------------
if [ -f ~/.bashrc-append ]; then
   source ~/.bashrc-append
   appended=true
fi

# ------------------------------------
# MOTD (Message of the Day)
# What you see when Terminal opens
# ------------------------------------
echo "----------------------------"
echo "Loaded $HOME/.bashrc"
if [ ${appended} ]; then
    echo "Appended $HOME/.bashrc-append"
fi
echo ""
echo "To edit run $ bashedit"
echo "To refresh run $ bashrefresh"
echo ""
echo "You are: `whoami`"
echo "You're in: `pwd`"
echo ""
printf "All aliases...\n$(alias)\n"
echo "----------------------------"

