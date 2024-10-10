package MetaCPAN::Role::Middleware;
use strict;
use warnings;

our $VERSION = 'v1.0.1';

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

=pod

=encoding UTF-8

=for Pod::Coverage wrap to_app

=head1 NAME

MetaCPAN::Role::Middleware - Moo role for creating Plack Middleware

=head1 METHODS

=head2 C<call($env)>

This method must be implemented in consumers of this role. It will be called
with a L<PSGI environment|PSGI/The Environment>. It should return a
L<PSGI response|PSGI/The Response>.

=head1 ATTRIBUTES

=head2 C<app>

The L<PSGI application|PSGI/Application> this middleware is wrapping.

=cut
