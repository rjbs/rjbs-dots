if [ -e /etc/fmhome/bashrc ]; then
  . /etc/fmhome/bashrc

  # Okay, this is pretty gross, but I keep getting slowed down because the VM
  # prompt no longer indicates when I'm root other than the word "root" among
  # a bunch of other letters.  GIVE ME BACK MY COLOR. -- rjbs, 2025-04-11 🧀💨
  if [ $UID = 0 ]; then
    __userhost="\[\033[1;32m\]root($FMADMIN)@\h$__inabox_name\[\033[0m\]$__dc_color"
  else
    __userhost="\u@\h$__inabox_name"
  fi

  if [ -e /etc/inaboxinfo/digitalocean.droplet-short-name ]; then
    export FMINABOX_NAME=`cat /etc/inaboxinfo/digitalocean.droplet-short-name | sed -e 's/\.rjbs$//'`;
    export FMINABOX_COLOR=`COLORTERM='' ~/bin/color-for $FMINABOX_NAME`
  fi

  PS1_BASE="$__dc_color[$FMENVIRONMENT $__userhost \W]"
  PS1_END="\\\$\[\033[0m\] "
fi

if [ ! -z "$SSH_AUTH_SOCK" ] \
  && [ ! -e "$HOME/.ssh/agent" ] \
  && [ "$SSH_AUTH_SOCK" != "$HOME/.ssh/agent" ]; \
then
  ln -snf "$SSH_AUTH_SOCK" "$HOME/.ssh/agent"
  export SSH_AUTH_SOCK="$HOME/.ssh/agent"
fi

source ~/.sh/host-color
