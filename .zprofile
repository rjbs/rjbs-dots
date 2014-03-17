uname=`uname`
if [ -x /usr/libexec/path_helper -a "$name" = "Dawrin" ]; then
  echo WARNING: /usr/libexec/path_helper is +x, your path will be messed up
fi
