use strict;
use warnings;

use Test::More;

use MetaCPAN::Common qw(visit dpath);

my $struct = {
  a => {
    b => {},
    c => 'd',
    e => [],
    f => [
      {
        g => 'h'
      },
      'i',
      {
        1 => 'j',
      },
    ],
  },
};

subtest 'visit' => sub {
  my @events = (
    ''        => $struct,
    'a'       => $struct->{a},
    'a.b'     => $struct->{a}{b},
    'a.c'     => $struct->{a}{c},
    'a.e'     => $struct->{a}{e},
    'a.f'     => $struct->{a}{f},
    'a.f.0'   => $struct->{a}{f}[0],
    'a.f.0.g' => $struct->{a}{f}[0]{g},
    'a.f.1'   => $struct->{a}{f}[1],
    'a.f.2'   => $struct->{a}{f}[2],
    'a.f.2.1' => $struct->{a}{f}[2]{1},
  );

  my $event = 0;
  my $clone = visit($struct, sub {
    my $path = join '.', @{+shift};
    $event++;
    my ($want_path, $want_element) = splice @events, 0, 2;
    is $path, $want_path, "event $event: correct path";
    if (ref) {
      is ref $_, ref $want_element, "event $event: correct element type";
    }
    else {
      is $_, $want_element, "event $event: correct element value";
    }
  });

  is scalar @events, 0, 'all events occurred';

  is_deeply $clone, $struct, 'returns clone';
  isnt $clone, $struct, 'clone is not the same ref';
  isnt $clone->{a}{b}, $struct->{a}{b}, 'deep clone is not the same ref';

  my $new = visit($struct, sub {
    ref or $_++;
  });

  is_deeply $new, {
    a => {
      b => {},
      c => 'e',
      e => [],
      f => [
        {
          g => 'i'
        },
        'j',
        {
          1 => 'k',
        },
      ],
    },
  }, '$_ modifies current element';

  is_deeply $struct, $clone, 'original struct is unmodified';
};

done_testing;
