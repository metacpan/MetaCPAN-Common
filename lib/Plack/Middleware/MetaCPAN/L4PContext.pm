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
  is      => 'ro',
  default => sub { qr/^Sec-|^Referer$/ },
);

has extras => (
  is      => 'ro',
  default => sub { {} },
);

my @headers = qw(
  Accept-CH
  Content-DPR
  Critical-CH
  DNT
  DPR
  ECT
  ETag
  Expect-CT
  NEL
  RTT
  Sec-CH-UA
  Sec-CH
  Sec-GPC
  SourceMap
  TE
  WWW-Authenticate
  X-DNS-Prefetch-Control
  X-XSS-Protection
);
my %header = map +(lc $_ => $_), @headers;
my ($match_headers) = map qr/$_/i, join '|', @headers;

sub _to_header {
  my ( $env_param ) = @_;
  if ($env_param =~ /^HTTP_(.*)$/) {
    my $header = ucfirst(lc($1) =~ s/_(.)/-\u$1/gr);
    if ($header =~ /^($match_headers)((?:-.*|\z))/) {
      return $header{lc $1} . $2;
    }
    return $header;
  }
  return undef;
}

sub call {
  my ( $self, $env ) = @_;
  my $extras    = $self->extras;
  my $header_rx = $self->headers;
  my $mdc       = Log::Log4perl::MDC->get_context;
  %$mdc = (
    ( $self->reset ? () : %$mdc ),
    ip     => $env->{REMOTE_ADDR},
    method => $env->{REQUEST_METHOD},
    url    => $env->{REQUEST_URI},
    (
      map +( exists $env->{$_} ? ( $_ => $env->{$_} ) : () ),
      keys %$extras
    ),
    (
      map {
        my $header = _to_header($_);
        $header && $header =~ $header_rx ? ( $header => $env->{$_} ) : ();
      } keys %$env
    ),
  );
  $self->app->($env);
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

=head2 extras

=cut
