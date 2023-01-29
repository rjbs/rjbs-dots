if [ -e /etc/fmhome/bashrc ]; then
  . /etc/fmhome/bashrc
fi

if [ ! -z "$SSH_AUTH_SOCK" ] \
  && [ ! -e "$HOME/.ssh/agent" ] \
  && [ "$SSH_AUTH_SOCK" != "$HOME/.ssh/agent" ]; \
then
  ln -snf "$SSH_AUTH_SOCK" "$HOME/.ssh/agent"
  export SSH_AUTH_SOCK="$HOME/.ssh/agent"
fi

source ~/.sh/host-color
