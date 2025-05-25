#!/usr/bin/perl
use v5.20.0;
use warnings;

use feature 'signatures';
no warnings 'experimental::signatures';

my $mode = $ARGV[0] || 'shell';

my @options = (
  [ { host => 'boojum' }    => [  33, 255,  26 ], 'more like BLUEJUM, am I right?' ],
  [ { host => 'tove' }      => [ 135, 255,  93 ], 'default host, default hue (purple)' ],
  [ { host => 'snark' }     => [ 202, 232, 166 ], 'orange you glad I picked it?' ],
  [ { host => 'wabe' }      => [  66, 232,     ], 'the color of moss on your sundial' ],
  [ { host => 'dodo' }      => [ 153, 232,     ], 'the pale blue-grey of a dodo' ],
  [ { host => 'dormouse' }  => [ 222, 232,     ], 'yellow as the fur of the dormouse' ],
  # [ { fm => 'boxdc' }       => [  51, 232,     ], 'cyan, following convention' ],
  [ { fm => 'boxdc' }       => [  94, 255,     ], 'brown, the color of the box emoji' ],
  [ { fm => 'phl' }         => [ 201, 232,     ], 'magenta, following convention' ],
  [ { fm => 'stl' }         => [ 226, 232,     ], 'yellow, following convention' ],
  [ { fm => '' }            => [ 225, 232,     ], 'unknown DC; the salmon of doubt' ],

  # [ 196, 255 ] # alarmingly red
);

my $default = [
  [ 247, 232 ], 'unknown identity, just kinda grey'
];

my sub assignments ($comment, $fg, $bg, $rv) {
  my sub xterm_to_rgb ($xtc) {
    # 232 .. 255 are greys
    if ($xtc >= 232) {
      my $tens = $xtc - 232;
      return sprintf('%02x', 8 + ($tens*10)) x 3;
    }

    my @HEX_FOR = qw( 00 5f 87 af d7 ff );
    $xtc -= 16;
    my $r = int $xtc / 36;
    my $g = int($xtc % 36 / 6);
    my $b = $xtc % 6;

    return join q{}, map { $HEX_FOR[$_] } $r, $g, $b;
  }

  return (
    "RJBS_HOST_COLOR=$fg # $comment",
    "RJBS_HOST_COLOR_BACKGROUND=$bg",
    "RJBS_HOST_COLOR_REVERSE=$rv",
    "RJBS_HOST_COLOR_RGB=" . xterm_to_rgb($fg),
    "RJBS_HOST_COLOR_BACKGROUND_RGB=" . xterm_to_rgb($bg),
    "RJBS_HOST_COLOR_REVERSE_RGB=" . xterm_to_rgb($rv),
  );
}

if ($mode eq 'shell') {
  my $str = qq{#!sh\nHOSTNAME=`hostname -s`\n};

  for my $option (@options) {
    my ($cond, $color, $comment) = @$option;
    my ($fg, $rv, $bg) = @$color;
    $bg //= $fg;

    my $cond_str;
    if (defined $cond->{host}) {
      $cond_str = qq{"\$HOSTNAME" = "$cond->{host}"};
    } elsif (defined $cond->{fm}) {
      my $fm = length $cond->{fm} ? ".$cond->{fm}" : $cond->{fm};
      $cond_str = qq{-e /etc/fmisproduction$fm};
    } else {
      die "weird condition that I didn't understand!\n";
    }

    $str .= join qq{\n},
      "if [ $cond_str ]; then",
      (map { "  $_" } assignments($comment, $fg, $bg, $rv)),
      "el";
  }

  my %default;
  @default{ qw( fg rv bg ) } = $default->[0]->@*;
  $default{bg} //= $default{fg};

  $str .= join qq{\n},
    "se",
    (map { "  $_" } assignments($default->[1], @default{qw(fg bg rv)})),
    "fi",
    "";

  $str .= "export RJBS_HOST_COLOR\n";
  $str .= "export RJBS_HOST_COLOR_BACKGROUND\n";
  $str .= "export RJBS_HOST_COLOR_REVERSE\n";

  print $str;
  exit;
}

# otherwise, DEMO MODE!!!
require Term::ANSIColor;
Term::ANSIColor->import('colored');

# set -g window-status-style fg=colour231,bg=colour238

for my $option (
  @options,
  [ {}, @$default ],
) {
  my ($cond, $color, $comment) = @$option;

  my $prompt = 'whereami';
  if (defined $cond->{host}) {
    $prompt = $cond->{host} || 'nowhere'
  } elsif (defined $cond->{fm}) {
    $prompt = $cond->{fm} ? "$cond->{fm}-example-01" : "wtf-example-02";
  }

  my ($fg, $rv, $bg) = @$color;
  $bg //= $fg;

  my $spacer = 50 - length $prompt;

  my sub greyspace {
    my ($w) = @_;
    $w //= 1;

    return colored([ "on_ansi238" ], ' ' x $w);
  }

  say greyspace()
    . colored([ "ansi$rv", "on_ansi$bg", 'bold' ], "1:crnt*") # current pane
    . greyspace()
    . colored([ "ansi231", "on_ansi238" ], "2:bkgr") # background pane
    . greyspace()
    . colored([ "ansi$fg", "on_ansi238" ], "2:actv") # pane with activity
    . greyspace($spacer)
    . colored([ "ansi238", "on_ansi0" ], '▛')
    . colored([ "ansi$fg", 'bold' ], " $prompt")
    . colored([ "ansi248" ], "/")
    . colored([ "ansi255" ], "0 ")
    . colored([ "ansi238", "on_ansi0" ], '▟')
    . "\n\n"
    . colored([ "ansi$fg", 'bold' ], $prompt)
    . colored([ "ansi255" ], ":~")
    . colored([ "ansi46" ], q{$ })
    . qq{echo "$comment"}
    ;

} continue {
  say colored([ 'ansi238' ], '─' x 78);
}
