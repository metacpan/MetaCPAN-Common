package Plack::Middleware::MetaCPAN::ReverseProxy;
use strict;
use warnings;

our $VERSION = 'v1.0.1';

use Moo;

use namespace::clean;

with qw(MetaCPAN::Role::Middleware);

sub call {
  my ( $self, $env ) = @_;
  if ( $env->{HTTP_FASTLY_SSL} ) {
    $env->{HTTPS}             = 'ON';
    $env->{'psgi.url_scheme'} = 'https';
  }
  if ( my $host = $env->{HTTP_X_FORWARDED_HOST} ) {
    $env->{HTTP_HOST} = $host;
  }
  if ( my $port = $env->{HTTP_X_FORWARDED_PORT} ) {
    $env->{SERVER_PORT} = $port;
  }
  if ( my $addrs = $env->{HTTP_X_FORWARDED_FOR} ) {
    my @addrs = map s/^\s+//r =~ s/\s+$//r, split /,/, $addrs;
    $env->{REMOTE_ADDR} = $addrs[0];
  }
  $self->app->($env);
}

1;
__END__

=head1 NAME

Plack::Middleware::MetaCPAN::ReverseProxy - ReverseProxy middleware for MetaCPAN

=cut
