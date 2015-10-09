use warnings;
use strict;

use charnames ':full';
use Irssi ();

our $VERSION = '0.001';
our %IRSSI = (
  authors => 'rjbs',
  name    => 'slack-emoji',
);

my %emoji = (
  'imp'   => "\N{IMP}",
  'heart' => "\N{BLUE HEART}", # Pobox, yo.
  'poop'  => "\N{PILE OF POO}",
  'smile' => "\N{SMILING FACE WITH OPEN MOUTH AND SMILING EYES}",
  '+1'    => "\N{THUMBS UP SIGN}",
  '-1'    => "\N{THUMBS DOWN SIGN}",
);

sub munge_emoji {
  my ($target, $text) = split / :/, $_[0], 2;
  $text =~ s!:([-+a-z0-9_]+):!$emoji{$1} // ":$1:"!ge;
  return "$target :$text";
}

sub expand_emoji {
  my ($server, $data, $nick, $address) = @_;
  return unless $server->{chatnet} =~ /slack/;

  Irssi::signal_stop();
  Irssi::signal_remove('event privmsg', 'expand_emoji');
  Irssi::signal_emit('event privmsg',
    $server,
    munge_emoji($data),
    $nick,
    $address,
  );
  Irssi::signal_add('event privmsg', 'expand_emoji');
}

Irssi::signal_add('event privmsg'  => 'expand_emoji');
