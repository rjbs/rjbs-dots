import re

def fm_nametrans_remote(folder):
  return re.sub('^INBOX\.', '', folder)

def fm_nametrans_local(folder):
  if folder == 'INBOX': return 'INBOX'
  return 'INBOX.' + folder
