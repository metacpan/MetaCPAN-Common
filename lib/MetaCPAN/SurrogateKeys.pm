package MetaCPAN::SurrogateKeys;
use strict;
use warnings;

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
