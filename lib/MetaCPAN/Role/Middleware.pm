package MetaCPAN::Role::Middleware;
use strict;
use warnings;

our $VERSION = 'v1.0.0';

use Moo::Role;

use namespace::clean;

has app => ( is => 'ro' );
requires 'call';

sub wrap {
  my ( $self, $app, @args ) = @_;
  my $args = $self->BUILDARGS(@args);
  $args = {
    ( ref $self ? %$self : () ),
    app => $app,
    %$args,
  };
  return $self->new($args)->to_app;
}

sub to_app {
  my $self = shift;
  return sub { $self->call(@_) };
}

1;
__END__

=head1 NAME

MetaCPAN::Role::Middleware - Moo role for creating Plack Middleware

=cut
