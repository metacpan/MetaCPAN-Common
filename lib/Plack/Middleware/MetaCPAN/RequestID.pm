package Plack::Middleware::MetaCPAN::RequestID;
use strict;
use warnings;

our $VERSION = 'v1.0.1';

use Moo;

use Digest::SHA;

use namespace::clean;

with qw(MetaCPAN::Role::Middleware);

has env_key => (
  is       => 'ro',
  required => 1,
);

sub call {
  my ( $self, $env ) = @_;

  $env->{ $self->env_key } = Digest::SHA::sha1_hex( join(
    "\0", $env->{REMOTE_ADDR}, $env->{REQUEST_URI}, time, $$, rand, ) );

  $self->app->($env);
}

1;
__END__

=pod

=encoding UTF-8

=for stopwords MDC

=head1 NAME

Plack::Middleware::MetaCPAN::RequestID - Generate a Request ID

=head1 ATTRIBUTES

=head2 env_key

=cut
