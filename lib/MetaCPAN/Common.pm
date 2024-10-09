package MetaCPAN::Common;
use strict;
use warnings;

our $VERSION = 'v1.0.1';

use Ref::Util qw(
  is_plain_arrayref
  is_plain_hashref
);

use namespace::clean;

use Exporter qw(import);

our @EXPORT_OK = qw(
  visit
);

sub visit {
  my ( $config, $cb ) = @_;
  my $new_config;
  my @queue = [ [], $config, \$new_config ];
  while (@queue) {
    my ( $path, $item, $new ) = @{ +pop @queue };
    if ( is_plain_hashref($item) ) {
      $$new = {};
      for my $key ( reverse sort keys %$item ) {
        push @queue, [ [ @$path, $key ], $item->{$key}, \($$new->{$key}) ];
      }
    }
    elsif ( is_plain_arrayref($item) ) {
      $$new = [];
      for my $i ( reverse 0 .. $#$item ) {
        push @queue, [ [ @$path, $i ], $item->[$i], \($$new->[$i]) ];
      }
    }
    else {
      $$new = $item;
    }
    for ($$new) {
      $cb->($path);
    }
  }
  return $new_config;
}

1;
__END__

=head1 NAME

MetaCPAN::Common - a collection of modules useful to MetaCPAN project

=head1 SYNOPSIS

  use MetaCPAN::Common qw(visit);

=head1 DESCRIPTION

Probably not useful to you unless you are developing either
L<https://metacpan.org> or L<https://fastapi.metacpan.org>.

These roles are shared between the MetaCPAN projects, the code base
of which can be found at L<https://github.com/metacpan/>.

=head1 FUNCTIONS

=head2 visit

  my $new = visit($data, $callback);

Constructs a clone of the C<$data> data structure, calling C<$callback> for
each element.

C<$callback> will be called with each node of the new structure. The new data
element aliased to C<$_> and will be passed the path to the element as an array
reference. For leaf nodes, the new data element will have a copy of the old
data. For other nodes, the new data element will be the new node under
construction, and will not have all of its data populated.

  my $new = visit(
    {
      foo => 'bar',
      baz => [
        {
          welp => 'asd',
        }
        'guff',
      ],
    },
    sub ($path) {
      ref or s/(.)/@$path:$1/;
    },
  );

  # $new will be:
  # {
  #   foo => 'foo:bar'
  #   baz => [
  #     {
  #       welp => 'baz 1 welp:asd',
  #     },
  #     'baz 2:guff',
  #   ],
  # }

=head1 AUTHOR

haarg - Graham Knop (cpan:HAARG) <haarg@haarg.org>

=head1 CONTRIBUTORS

None so far.

=head1 COPYRIGHT

Copyright (c) 2024 the MetaCPAN::Common L</AUTHOR> and L</CONTRIBUTORS>
as listed above.

=head1 LICENSE

This library is free software and may be distributed under the same terms
as perl itself. See L<https://dev.perl.org/licenses/>.

=cut
