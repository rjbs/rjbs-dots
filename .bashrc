if [ -e /etc/fmhome/bashrc ]; then
  . /etc/fmhome/bashrc

  if [ -e /etc/inaboxinfo/digitalocean.droplet-short-name ]; then
    export FMINABOX_NAME=`cat /etc/inaboxinfo/digitalocean.droplet-short-name | sed -e 's/\.rjbs$//'`;
    export FMINABOX_COLOR=`COLORTERM='' COLOR_FOR_XTERM=1 ~/bin/color-for $FMINABOX_NAME`

    __dc_color="\[\033[38;5;178m\]" # Brown like a box
    GREEN="\[\033[38;5;119m\]"
    RED="\[\033[91m\]"
    RESET="\[\033[0m\]"

    # Okay, this is pretty gross, but I keep getting slowed down because the VM
    # prompt no longer indicates when I'm root other than the word "root" among
    # a bunch of other letters.  GIVE ME BACK MY COLOR. -- rjbs, 2025-04-11 🧀💨
    if [ $UID = 0 ]; then
      PS1_BASE="${GREEN}[⭑ ${__dc_color}$FMADMIN@$FMINABOX_NAME:\W${GREEN}]"
      PS1_END="${RED}# $RESET"
    else
      PS1_BASE="${__dc_color}[\u@$FMINABOX_NAME:\W]"
      PS1_END="${GREEN}\$ $RESET"
    fi
  fi
fi

if [ ! -z "$SSH_AUTH_SOCK" ] \
  && [ ! -e "$HOME/.ssh/agent" ] \
  && [ "$SSH_AUTH_SOCK" != "$HOME/.ssh/agent" ]; \
then
  ln -snf "$SSH_AUTH_SOCK" "$HOME/.ssh/agent"
  export SSH_AUTH_SOCK="$HOME/.ssh/agent"
fi

source ~/.sh/host-color

command which fzf > /dev/null && source ~/.fzfenv && eval "$(fzf --bash)"
