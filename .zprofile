uname=`uname`
if [ -x /usr/libexec/path_helper -a "$uname" = "Darwin" ]; then
  echo WARNING: /usr/libexec/path_helper is +x, your path will be messed up
fi
