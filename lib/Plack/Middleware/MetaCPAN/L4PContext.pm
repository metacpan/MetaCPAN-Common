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

has headers => (
  is => 'ro',
  default => sub { qr/^Sec-|^Referer$/ },
);

sub call {
  my ( $self, $env ) = @_;
  my $header_rx = $self->headers;
  my $mdc = Log::Log4perl::MDC->get_context;
  %$mdc = (
    ( $self->reset ? () : %$mdc ),
    ip     => $env->{REMOTE_ADDR},
    method => $env->{REMOTE_METHOD},
    url    => $env->{REQUEST_URI},
    map {
      if (/^HTTP_(.*)$/) {
        my $header = lc($1) =~ s/_(.)/-\u$1/gr;
        my $value = $env->{$_};
        if ($header =~ $header_rx) {
          ($header => $value);
        }
        else {
          ();
        }
      }
      else {
        ();
      }
    } keys %$env
  );
  $self->app($env);
}

1;
__END__

=pod

=encoding UTF-8

=for stopwords MDC

=head1 NAME

Plack::Middleware::MetaCPAN::L4PContext - Log4perl MDC population from request data

=head1 ATTRIBUTES

=head2 reset

=head2 headers

=cut
