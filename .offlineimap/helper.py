import re

def fm_nametrans_remote(folder):
  return re.sub('^INBOX\.', '', folder)

def fm_nametrans_local(folder):
  if folder == 'INBOX': return 'INBOX'
  return 'INBOX.' + folder

prioritized = [ 'Sent', 'Archive.2019.11' ]

def mycmp(x, y):
  for prefix in prioritized:
    xsw = x.startswith(prefix)
    ysw = y.startswith(prefix)
    if xsw and ysw:
      return cmp(x, y)
    elif xsw:
      return -1
    elif ysw:
      return +1
  return cmp(x, y)

