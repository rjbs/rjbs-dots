## rjbs's .zshrc
uname=`uname`

if [ "$uname" != "SunOS" ]; then
  export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin
fi

if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

for file in $HOME/.zprivate/*(N); do
  source $file
done

for file in $HOME/.sh/func/*(N); do
  source $file
done

for file in $HOME/.zsh/func/*(N); do
  source $file
done

# I'll need this for colorized prompt.
autoload -U colors

export GNUPG_DEFAULT_KEY=C475DCA3
export IRCNICK=rjbs
export MAILDOMAIN=manxome.org
export PERL_AUTOINSTALL=--skipdeps

export HISTFILE=~/.zhistory
export SAVEHIST=1000

# Stupid OS X
export COPYFILE_DISABLE=1
export COPYFILE_EXTENDED_ATTRIBUTES_DISABLE=1

# I edit things in Vim.
export EDITOR=vim
export VISUAL=vim

# pager and manpager setup
export LESS="-M -x 2 -R"
export LESSOPEN=$'|lesspipe %s'
export MANPAGER="/bin/sh -c \"col -b | view -c 'set ts=8 ft=man nomod nolist' -\""
export MANPATH=$MANPATH:/opt/local/share/man
export MANWIDTH=80
export PAGER=less
export PERLDOC=-otext

if [ -z "$NOPASTE_SERVICES" ]; then
  export NOPASTE_SERVICES=Gist
fi

if [ -d "/opt/homebrew" ]; then
  # added 2022-07-26, probably should be cleaned up
  export HOMEBREW_PREFIX="/opt/homebrew";
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
  export HOMEBREW_REPOSITORY="/opt/homebrew";
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
  export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
  export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";
fi

if [ -d $HOME/.plenv ]; then
  export PATH=$HOME/.plenv/bin:$PATH

  if which plenv > /dev/null; then eval "$(plenv init - zsh)"; fi
fi

if [ -d $HOME/.rbenv ]; then
  export PATH=$HOME/.rbenv/bin:$PATH
  eval "$(rbenv init -)"
fi

if [ -d $HOME/.rakubrew ]; then
  eval "$($HOME/.rakubrew/bin/rakubrew init Zsh)"
fi

if [ -d $HOME/.cargo ]; then
  source $HOME/.cargo/env
fi

# Everything above that might have stuck things into our $PATH is now complete,
# so we can finally put ~/bin at the head of the path!
export PATH=$HOME/bin:$PATH

source ~/.sh/host-color

export PS1="%{[1m%}%F{$RJBS_HOST_COLOR}%m%f:%~%(!.%F{red}#.%F{46}$)%f%{[0m%} "

# I used to have an ephemeral right-hand prompt with hostname and time.  This
# was nice because it kept my hostname in view, but the time was not very
# useful most of the time, and the history number (also often there) was even
# less so.  I should look at how to put things like history number, exit
# status, and time info into my session… but the prompt isn't the best way.
# -- rjbs, 2021-06-27
# export RPS1="%F{$HOSTCOLOR}%m%f @ %D{%H:%M:%S}"

export EDITOR=$(which vi)
export SENDMAIL=$(which sendmail)
export VISUAL=$(which vi)

export PERL_MAILERS=sendmail:$SENDMAIL

if [ -e "${HOME}/.iterm2_shell_integration.zsh" ]; then
  source "${HOME}/.iterm2_shell_integration.zsh"
fi

# ugh, hate; the first is to prevent "no entry in hash table for man"
alias man=man
unalias man

# gotta have my colorized ls listings!
dirc=$(whiff dircolors gdircolors);
[ $? -eq 0 ] && eval $($dirc -b ~/.dir_colors | grep LS_COLORS)

# By excluding /, this lets me hit <C-w> to delete part of a path.
export WORDCHARS='*?[]~=&!#$%^(){}<>'

bindkey -v  # the dreaded vi mode!!

bindkey -s "^?" "^H" # sometimes, a terminal thinks backspace is delete
bindkey "^[[3~" delete-char # I have no idea why this is here.
bindkey "^R" history-incremental-search-backward # vi mode's version sux
bindkey ' ' magic-space # expand history at space

# It used to be that at work, I'd encounter ^W to delete line.  I'd try to
# delete one word and then lost my whole big command and then lose my mind and
# moan and scream.  No more! -- rjbs, 2015-06-19
bindkey "^W" backward-delete-word

setopt    autopushd             # cd implies pushd
setopt no_auto_remove_slash     # ls /symli<Tab> should list contents, not ln
setopt no_autoresume            # if running something already bg'd, don't fg
setopt no_correct               # disable spellchecking
setopt no_correct_all           # disable spellchecking
setopt no_cdable_vars           # disable cd to homedir
setopt    extended_history      # timestamps, etc, in .zhistory
setopt    histignoredups        # don't log an item to history twice in a row
setopt    inc_append_history    # update .zhistory in closer to real time
setopt    interactive_comments  # let # make comments even interactive!
setopt no_nomatch               # if a wildcard can't expand, leave it verbatim
setopt no_printexitvalue        # <-- yuck, printexitvalue
setopt    transient_rprompt     # rprompt goes away after command is run

## BELOW THIS, EVERYTHING IS BASICALLY CARGO CULTED

# The following lines were added by compinstall
_compdir=/usr/share/zsh/${ZSH_VERSION}/functions
[[ -z $fpath[(r)$_compdir] ]] && fpath=($fpath $_compdir)

autoload -U compinit
compinit

zstyle ':completion:*' completer _expand _complete # _approximate
zstyle ':completion:*' completer _expand _complete:-equal-
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=5
# End of lines added by compinstall

## stop history searches at beginning/end of list
zstyle ':completion:*:history-words' stop verbose

## Ignore directories named CVS
zstyle ':completion:*:(all-|)files' ignored-patterns '(|*/)CVS'
zstyle ':completion:*:cd:*' ignored-patterns '(*/)#CVS'

## Make sure modules are loaded
zmodload -i zsh/zutil
zmodload -i zsh/compctl
zmodload -i zsh/complete
zmodload -i zsh/complist
zmodload -i zsh/computil
zmodload -i zsh/main
zmodload -i zsh/zle
zmodload -i zsh/rlimits
zmodload -i zsh/parameter

## setup predicting completer
autoload -U predict-on
zle -N predict-on
zle -N predict-off

autoload -U zrecompile

if [ `uname` = "SunOS" ]; then
  /usr/bin/stty dsusp undef
  if /usr/bin/stty -a | grep -q 'status =' ; then
    /usr/bin/stty status undef
  fi
fi

# from http://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity
# the idea here is to make C-z on a blank line act like running fg
fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}

zle -N fancy-ctrl-z

vi-push-line-or-edit () { zle push-line; bindkey -v }
zle -N vi-push-line-or-edit

bindkey '^Z' fancy-ctrl-z
bindkey -M vicmd 'z' vi-push-line-or-edit

autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'Z' edit-command-line
