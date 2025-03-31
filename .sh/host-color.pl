#!/usr/bin/perl
use v5.12.0;
use warnings;

my $mode = $ARGV[0] || 'shell';

my @options = (
  [ { host => '' }          => [ 247,   0 ], 'no hostname! dim unto death' ],
  [ { host => 'boojum' }    => [  33, 255 ], 'more like BLUEJUM, am I right?' ],
  [ { host => 'snowdrop' }  => [ 135, 255 ], 'default host, default hue (purple)' ],
  [ { host => 'snark' }     => [ 202,   0 ], 'orange you glad I picked it?' ],
  [ { host => 'wabe' }      => [  66, 255 ], 'the color of moss on your sundial' ],
  [ { host => 'dormouse' }  => [ 222,   0 ], 'yellow as the fur of the dormouse' ],
  [ { fm => 'boxdc' }       => [  51,   0 ], 'cyan, following convention' ],
  [ { fm => 'nyi' }         => [ 196, 255 ], 'red, following convention' ],
  [ { fm => 'west' }        => [ 226,   0 ], 'yellow, following convention' ],
  [ { fm => '' }            => [ 225,   0 ], 'unknown DC; the salmon of doubt' ],
);

my $default = [
  [ 201, 0 ], 'bright pink; where ARE we??'
];

if ($mode eq 'shell') {
  my $str = qq{#!sh\nHOSTNAME=`hostname -s`\n};

  for my $option (@options) {
    my ($cond, $color, $comment) = @$option;
    my ($fg, $rv) = @$color;

    my $cond_str;
    if (defined $cond->{host}) {
      $cond_str = qq{"\$HOSTNAME" = "$cond->{host}"};
    } elsif (defined $cond->{fm}) {
      my $fm = length $cond->{fm} ? ".$cond->{fm}" : $cond->{fm};
      $cond_str = qq{-e /etc/fmisproduction$fm};
    } else {
      die "weird condition that I didn't understand!\n";
    }

    $str .= "if [ $cond_str ]; then\n"
         .  "  RJBS_HOST_COLOR=$fg # $comment\n"
         .  "  RJBS_HOST_COLOR_REVERSE=$rv\n"
         .  "el";
  }

  $str .= "se\n"
        . "  RJBS_HOST_COLOR=$default->[0][0] # $default->[1]\n"
        . "  RJBS_HOST_COLOR_REVERSE=$default->[0][1]\n"
        . "fi\n";

  $str .= "export RJBS_HOST_COLOR\n";
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

  my $fg = $color->[0];
  my $rv = $color->[1] ? 255 : 0;

  my $spacer = 60 - length $prompt;

  say colored([ "on_ansi238" ], ' ')
    . colored([ "ansi$rv", "on_ansi$fg" ], "1:demo*")
    . colored([ "on_ansi238" ], ' ')
    . colored([ "ansi231", "on_ansi238" ], "2:etc")
    . colored([ "on_ansi238" ], ' ' x $spacer)
    . colored([ "ansi238", "on_ansi0" ], '▛')
    . colored([ "ansi$fg" ], " $prompt ")
    . colored([ "ansi238", "on_ansi0" ], '▟')
    . "\n\n"
    . colored([ "ansi$fg" ], $prompt)
    . colored([ "ansi255" ], ":~")
    . colored([ "ansi46" ], q{$ })
    . qq{echo "$comment"}
    ;

} continue {
  say colored([ 'ansi238' ], '─' x 78);
}
