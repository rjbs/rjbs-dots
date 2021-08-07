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

# I'll need this for colorized prompt.
autoload -U colors

export PERL_AUTOINSTALL=--skipdeps
export EDITOR=vim
export VISUAL=vim
export GNUPG_DEFAULT_KEY=C475DCA3
export IRCNICK=rjbs
export LESS="-M -x 2 -R"
export LESSOPEN=$'|lesspipe %s'
export MAILDOMAIN=manxome.org
export MANPATH=$MANPATH:/opt/local/share/man
export MANWIDTH=80
export PERLDOC=-otext

if [ -e /etc/ssl/certs/ca-certificates.crt ]; then
  export CERTFILE=/etc/ssl/certs/ca-certificates.crt
elif [ -e /usr/local/etc/openssl/cert.pem ]; then
  export CERTFILE=/usr/local/etc/openssl/cert.pem
fi

if [ "$uname" = "Darwin" ]; then
  export PATH=/opt/local/bin:/opt/local/sbin:/usr/local/texlive/2015/bin/x86_64-darwin:$PATH
fi

if [ -d $HOME/.plenv ]; then
  export PATH=$HOME/.plenv/bin:$PATH
fi

if which plenv > /dev/null; then eval "$(plenv init - zsh)"; fi

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

export PAGER=less

# . /icg/admin/include/paths.sh
export PATH=$HOME/bin:$PATH

view=$(which view)
export MANPAGER="/bin/sh -c \"col -b | $view -c 'set ts=8 ft=man nomod nolist' -\""

if [ -z "$NOPASTE_SERVICES" ]; then
  export NOPASTE_SERVICES=Gist
fi

# Stupid OS X
export COPYFILE_DISABLE=1
export COPYFILE_EXTENDED_ATTRIBUTES_DISABLE=1

export HISTFILE=~/.zhistory
export SAVEHIST=1000

HOSTNAME=`hostname -s`
if [ -z "$HOSTNAME" ]; then
  RJBS_HOST_COLOR=247 # no hostname! dim unto death
elif [ "$HOSTNAME" = "dinah" ]; then
  RJBS_HOST_COLOR=141 # lovely lavendar
elif [ "$HOSTNAME" = "snark" ]; then
  RJBS_HOST_COLOR=202 # orange you glad I picked this color?
elif [ "$HOSTNAME" = "wabe" ]; then
  RJBS_HOST_COLOR=66  # the color of moss on your sundial
elif [ "$HOSTNAME" = "bill" ]; then
  RJBS_HOST_COLOR=40  # green, because Bill is a lizard
elif [ "$HOSTNAME" = "dormouse" ]; then
  RJBS_HOST_COLOR=222 # yellow as the fur of the dormouse
elif [ -d "/var/icg" ]; then
  RJBS_HOST_COLOR=27  # blue, in honor of Pobox
elif [ -d "/etc/fmisproduction.boxdc" ]; then
  RJBS_HOSTCOLOR=51   # cyan, following convention
elif [ -d "/etc/fmisproduction.nyi" ]; then
  RJBS_HOSTCOLOR=196  # red, following convention
elif [ -d "/etc/fmisproduction.west" ]; then
  RJBS_HOSTCOLOR=226  # yellow, following convention
elif [ -d "/etc/fmisproduction" ]; then
  RJBS_HOSTCOLOR=225  # unknown DC; the salmon of doubt
else
  RJBS_HOST_COLOR=201 # bright pink; where ARE we??
fi

export RJBS_HOST_COLOR

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

# Once I figured out this was breaking my F2 at work on Solaris, I fixed our
# global config.  I've left this here for future reference. -- rjbs, 2009-01-08
# if [ $OSTYPE == "SunOS" ]; then
#   export TERMINFO=/usr/pkg/share/lib/terminfo
# fi

if [ -e $HOME/code/hla ]; then
  export hlalib=$HOME/code/hla/hlalib
  export hlainc=$HOME/code/hla/include
  export PATH=$PATH:$HOME/code/hla
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
