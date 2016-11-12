use warnings;
use strict;

use Text::SlackEmoji;
use Irssi ();

our $VERSION = '0.001';
our %IRSSI = (
  authors => 'rjbs',
  name    => 'slack-emoji',
);

my %emoji = %{ Text::SlackEmoji->emoji_map };

$emoji{pobox} = "[\N{BLUE HEART} \N{INCOMING ENVELOPE} ]";

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


sub cmd_reloademoji {
  Text::SlackEmoji->load_emoji;
  Irssi::print("emoji reloaded");
  return;
}

Irssi::command_bind('reloademoji', 'cmd_reloademoji');
