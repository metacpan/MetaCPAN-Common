package Plack::Middleware::MetaCPAN::CSP;
use strict;
use warnings;

our $VERSION = 'v1.0.1';

use Moo;

use MetaCPAN::CSP   ();
use Plack::Util     ();
use Types::Standard qw(Str Enum HashRef ArrayRef);

use namespace::clean;

with qw(MetaCPAN::Role::Middleware);

has policy => (
  is      => 'ro',
  default => sub { +{} },
  isa     => ( HashRef [ArrayRef] ),
);

has digest => (
  is      => 'ro',
  default => 'sha256',
  isa     => Enum [qw(sha256 sha384 sha512)],
);

sub call {
  my ( $self, $env ) = @_;

  my $csp = MetaCPAN::CSP->new(
    policy => $self->policy,
    digest => $self->digest,
  );

  $env->{'csp.add'}       = sub { $csp->add(@_) };
  $env->{'csp.nonce_for'} = sub { $csp->nonce_for(@_) };
  $env->{'csp.sha_for'}   = sub { $csp->sha_for(@_) };

  Plack::Util::response_cb(
    $self->app->($env),
    sub {
      my $res = shift;
      Plack::Util::header_set( $res->[1],
        'Content-Security-Protocol' => $csp->header );
    }
  );
}

1;
__END__

=pod

=encoding UTF-8

=head1 NAME

Plack::Middleware::MetaCPAN::CSP - CSP header configuration for MetaCPAN

=head1 DESCRIPTION

Adds a L<< C<Content-Security-Protocol>|https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy >> header to responses, based on a default configuration, and allowing
applications to add their own rules.

=head1 ATTRIBUTES

=head2 policy

The starting policy to use. A hash ref of array refs.

  {
    'default-src' => q[qw(* data:)],
    'script-src'  => q[qw('self')],
  }

=head2 digest

The digest to use when calculating a digest for a header. Can be one of
C<sha256>, C<sha384>, or C<sha512>. Defaults to C<sha256>.

=head1 PSGI Environment

Callbacks will be added to the PSGI environment which will add entries to the
CSP policy.

=over 4

=item C<csp.add>

Accepts pairs of directives and values to add to the CSP.

  $env->{'csp.add'}->(
    'script-src' => 'data:',
    'img-src'    => 'data:',
  );

=item C<csp.nonce_for>

Accepts a directive, generates a nonce value, adds it to the CSP policy, and
returns it.

  my $nonce = $env->{'csp.nonce_for'}->('script-src');
  my $tag = qq[<script nonce="$nonce">alert("allowed")</script>];
  # policy includes "script-src 'nonce-$nonce'"

=item C<csp.sha_for>

Accepts a directive and content, generates a digest for the content, adds it to
the CSP policy, and returns the digest.

  my $script = 'alert("allowed");';
  my $digest = $env->{'csp.sha_for'}->('script-src', $script);
  my $tag = qq[<script>$script</script>];
  # policy includes "script-src 'sha256-$digest'"

=back

=head1 SEE ALSO

=over 4

=item * L<MetaCPAN::CSP>

=back

=cut
