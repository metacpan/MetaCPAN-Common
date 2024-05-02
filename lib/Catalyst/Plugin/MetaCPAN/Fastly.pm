package Catalyst::Plugin::MetaCPAN::Fastly;

use Moose::Role;

use MetaCPAN::SurrogateKeys qw(
  keys_for_author
  keys_for_dist
  keys_for_type
);

use namespace::clean;

with qw(CatalystX::Fastly::Role::Response);

sub add_user_key {
  my ( $c, $author ) = @_;

  for my $key ( keys_for_user($author) ) {
    $c->add_surrogate_key($key);
  }
}

sub add_author_key {
  my ( $c, $author ) = @_;

  for my $key ( keys_for_author($author) ) {
    $c->add_surrogate_key($key);
  }
}

sub add_dist_key {
  my ( $c, $dist ) = @_;

  for my $key ( keys_for_author($dist) ) {
    $c->add_surrogate_key($key);
  }
}

before 'finalize' => sub {
  my $c = shift;

  if ( $c->cdn_max_age ) {

    # We've decided to cache on Fastly, so throw fail overs
    # if there is an error at origin
    $c->cdn_stale_if_error('30d');
  }

  for my $key ( keys_for_type( $c->res->content_type ) ) {
    $c->add_surrogate_key($key);
  }
};

1;
__END__

=head1 NAME

Catalyst::Plugin::MetaCPAN::Fastly - Methods for Catalyst Fastly API integration

=head1 SYNOPSIS

    use Catalyst qw(
        MetaCPAN::Fastly
    );

=head1 DESCRIPTION

This role includes L<CatalystX::Fastly::Role::Response>.

Surrogate keys for the content type will be automatically added to the response
headers.

=head1 METHODS

=head2 $c->add_author_key('Ether');

Adds surrogate keys for the author C<ETHER> to the response headers. Author
names will be normalized to upper case.

=head2 $c->add_dist_key('Moose');

Adds surrogate keys for the distribution C<Moose> to the response headers.

=head2 $c->add_user_key($id);

Adds surrogate keys for the given user.

