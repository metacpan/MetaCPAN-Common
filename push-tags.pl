#!/usr/bin/env perl
use v5.36;

my $version = shift;
my @parts = $version =~ /\Av(\d+)\.(\d+)\.(\d+)\z/;

my @short_versions = ("v$parts[0]", "v$parts[0]\.$parts[1]");

system 'git', 'push', 'origin', '-f', map "$version:$_", @short_versions;
