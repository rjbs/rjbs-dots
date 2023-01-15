export LANG=en_US.UTF-8

if [ ! -z "$SSH_AUTH_SOCK" ] \
  && [ ! -e "$HOME/.ssh/agent" ] \
  && [ "$SSH_AUTH_SOCK" != "$HOME/.ssh/agent" ]; \
then
  ln -snf "$SSH_AUTH_SOCK" "$HOME/.ssh/agent"
  export SSH_AUTH_SOCK="$HOME/.ssh/agent"
fi

if [ -e "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi
