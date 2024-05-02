package Plack::Middleware::MetaCPAN::L4PContext;
use strict;
use warnings;

our $VERSION = 'v1.0.1';

use Moo;

use Log::Log4perl::MDC ();

use namespace::clean;

with qw(MetaCPAN::Role::Middleware);

has reset => (
  is      => 'ro',
  default => !!1,
);

sub call {
  my ( $self, $env ) = @_;
  my $mdc = Log::Log4perl::MDC->get_context;
  %$mdc = (
    ( $self->reset ? () : %$mdc ),
    ip     => $env->{REMOTE_ADDR},
    method => $env->{REMOTE_METHOD},
    url    => $env->{REQUEST_URI},
    map +(
      lc($_) =~ s/_(.)/-\u$1/gr =~ s/^http-//r => $env->{$_}
    ),
    grep /^HTTP_(?:SEC_|REFERER$)/,
    keys %$env
  );
  $self->app($env);
}

1;
__END__

=for stopwords MDC

=head1 NAME

Plack::Middleware::MetaCPAN::L4PContext - Log4perl MDC population from request data

=cut
