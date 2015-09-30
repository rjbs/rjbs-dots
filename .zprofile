uname=`uname`

# Disabled because /usr/libexec/path_helper can't be chmodded even by root on
# OS X 10.11, unless I disable SIP.
#
# if [ -x /usr/libexec/path_helper -a "$uname" = "Darwin" ]; then
#   echo WARNING: /usr/libexec/path_helper is +x, your path will be messed up
# fi
