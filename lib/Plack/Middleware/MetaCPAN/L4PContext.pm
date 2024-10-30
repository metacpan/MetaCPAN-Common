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

=head1 DESCRIPTION

Populates the L<Log4perl MDC|Log::Log4perl::MDC> with values taken from the
L<PSGI> environment.

Includes the following keys:

=over 4

=item C<ip>

The remove address. Taken from C<REMOTE_ADDR>.

=item C<method>

The request method. Taken from C<REQUEST_METHOD>.

=item C<url>

The request URL. Taken from C<REQUEST_URI>.

=back

=head1 ATTRIBUTES

=head2 reset

Clear all existing values from the Log4perl context before adding. Defaults to
true.

=head2 headers

A regex for HTTP headers to include in the Log4perl context. Defaults to
C<qr/^Sec-|^Referer$/>.

=head2 extras

An array ref of additional L<PSGI> environment keys to include in the context.

=cut
