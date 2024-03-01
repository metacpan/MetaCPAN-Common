package Plack::Middleware::MetaCPAN::CSP;
use Moo;

use MetaCPAN::CSP   ();
use Plack::Util     ();
use Types::Standard qw(Str Enum HashRef ArrayRef);

use namespace::clean;

with qw(MetaCPAN::Role::Middleware);

has policy => (
  is      => 'ro',
  default => sub { +{} },
  isa     => ( HashRef [ArrayRef] )->plus_coercions(
    HashRef [Str] => sub {
      my $hash = shift;
      +{ map +( $_ => [ split /;\s*/, $hash->{$_} ] ), keys %$hash };
    },
  ),
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

  $env->{'csp.amend'}     = sub { $csp->amend(@_) };
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
