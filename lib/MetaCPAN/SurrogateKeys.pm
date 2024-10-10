package MetaCPAN::SurrogateKeys;
use strict;
use warnings;

our $VERSION = 'v1.0.1';

use Exporter qw(import);

our @EXPORT_OK = qw(
  keys_for_author
  keys_for_dist
  keys_for_frontend
  keys_for_type
  keys_for_user
);

sub keys_for_user {
  return
    map 'user=' . $_,
    @_;
}

sub keys_for_author {
  return
    map 'author=' . $_,
    map uc,
    @_;
}

sub keys_for_dist {
  return
    map 'dist=' . $_,
    map uc,
    map s{:}{-}gr,
    @_;
}

sub keys_for_type {
  return
    map 'content_type=' . $_,
    map +( s{;.*}{}r, s{/.*}{}r, ),
    @_;
}

sub keys_for_frontend {
  qw(
    ROBOTS
    RECENT
    DIST_UPDATES
    ABOUT
    STATIC
    SOURCE
    NEWS
  );
}

1;
__END__

=pod

=encoding UTF-8

=head1 NAME

MetaCPAN::SurrogateKeys - Surrogate keys for MetaCPAN content

=head1 METHODS

=head2 keys_for_user

=head2 keys_for_author

=head2 keys_for_dist

=head2 keys_for_type

=head2 keys_for_frontend

=cut
