uname=`uname`
if [ -x /usr/libexec/path_helper -a "$name" = "Darwin" ]; then
  echo WARNING: /usr/libexec/path_helper is +x, your path will be messed up
fi
