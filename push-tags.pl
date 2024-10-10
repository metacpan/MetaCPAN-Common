#!/usr/bin/env perl
use v5.36;

my $version = shift;
my @parts = $version =~ /\Av(\d+)\.(\d+)\.(\d+)(-TRIAL)?\z/;

die "Invalid version $version!\n"
  if !@parts;

exit
  if !$parts[3];

my $tag_ref = `git rev-parse --verify -q $version`;
chomp $tag_ref;
if (!$tag_ref) {
  die "No tag for version $version!\n";
}

my @short_versions = ("v$parts[0]", "v$parts[0]\.$parts[1]");

for my $v (@short_versions) {
  system 'git', 'update-ref', '-d', "refs/tags/$v"
  system 'git', 'tag', $v, $version;
}

system 'git', 'push', 'origin', '-f', @short_versions;
