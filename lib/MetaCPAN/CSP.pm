package MetaCPAN::CSP;
use strict;
use warnings;

our $VERSION = 'v1.0.1';

use Moo;

use Crypt::URandom          qw(urandom_ub);
use Digest::SHA             ();
use Math::Random::ISAAC::XS ();
use Types::Standard         qw(Enum HashRef ArrayRef);

use namespace::clean;

has policy => (
  is      => 'ro',
  default => sub { +{} },
  isa     => HashRef [ArrayRef],
);

has _directives => (
  is      => 'ro',
  default => sub {
    my $self   = shift;
    my $policy = $self->policy;
    return {
      map +( $_ => { map +( $_ => 1 ), @{ $policy->{$_} } } ),
      keys %$policy
    };
  },
);

sub _build_nonce_generator {
  my $rng = Math::Random::ISAAC::XS->new( unpack( "C*", urandom_ub(16) ) );
  sub {
    sprintf( '%x', $rng->irand );
  };
}

has nonce_gen => (
  is      => 'lazy',
  builder => 1,
);

has nonce => (
  is      => 'lazy',
  default => sub { $_[0]->nonce_gen->() },
);

my $digest_type = Enum [qw(sha256 sha384 sha512)];

has digest => (
  is      => 'ro',
  default => 'sha256',
  isa     => $digest_type,
);

my %digest_sub = map { ## no critic (BuiltinFunctions::ProhibitComplexMappings)
  my $sub = do {
    no strict 'refs';
    \&{ 'Digest::SHA::' . $_ . '_base64' };
  };
  +(
    $_ => sub {
      my $digest = $sub->(shift);
      $digest . '=' x ( 4 - length($digest) % 4 );
    }
  )
} @{ $digest_type->values };

sub add {
  my ( $self, @amend ) = @_;
  my $directives = $self->_directives;
  while ( my ( $directive, $policy ) = splice @amend, 0, 2 ) {
    my $dir = $directives->{$directive} ||= {};
    $dir->{$_} = 1 for map split(' '), ref $policy ? @$policy : $policy;
  }
  return;
}

sub nonce_for {
  my ( $self, $directive ) = @_;
  my $directives = $self->_directives;
  my $nonce      = $self->nonce;
  $directives->{$directive}{"'nonce-$nonce'"} = 1;
  return $nonce;
}

sub sha_for {
  my ( $self, $directive, $content ) = @_;
  my $directives = $self->_directives;
  my $alg        = $self->digest;
  my $digest     = $digest_sub{$alg}->($content);
  $directives->{$directive}{"'$alg-$digest'"} = 1;
  return $digest;
}

sub header_value {
  my ($self) = @_;
  my $directives = $self->_directives;
  return join '; ',
    map join( ' ', $_, sort keys %{ $directives->{$_} }, ),
    sort keys %$directives;
}

1;
__END__

=pod

=encoding UTF-8

=head1 NAME

MetaCPAN::CSP - Object for generating Content-Security-Policy headers

=head1 ATTRIBUTES

=head2 digest

The digest algorithm to use. Can be one of C<sha256>, C<sha384>, or C<sha512>.
Defaults to C<sha256>.

=head2 nonce_gen

A subroutine reference that generates a random string to use for a nonce.
Defaults to generating a hex string using L<Math::Random::ISAAC::XS>.

=head2 policy

The starting policy as a hash ref of array refs.

  {
    'default-src' => q[qw(* data:)],
    'script-src'  => q[qw('self')],
  }

This attribute will not reflect any modifications done by other methods.

=head1 METHODS

=head2 add ( $directive, $rule, ... )

Accepts pairs of directives and rules, and adds them to the policy.

=head2 nonce_for ( $directive )

Generates a nonce, adds it to the policy, and returns it.

=head2 sha_for ( $directive, $content )

Generates a digest of the content, adds it to the policy, and return it.

=head2 header_value

Returns the CSP policy as a string to be used at the C<Content-Security-Policy>
header.

=cut
