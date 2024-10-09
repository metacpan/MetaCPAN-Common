package MetaCPAN::Role::Config;
use strict;
use warnings;

our $VERSION = 'v1.0.1';

{ use Moo::Role; }

use Config::ZOMG;
use File::Spec::Functions qw(rel2abs);
use Carp                  qw(croak confess);
use MetaCPAN::Common      qw(visit);

use namespace::clean;

has name => (
  is       => 'ro',
);

has path => (
  is       => 'ro',
  coerce   => sub { defined $_[0] ? rel2abs( $_[0] ) : undef },
);

has config => (
  is      => 'ro',
  lazy    => 1,
  builder => 1,
  clearer => '_clear_config',
);

sub _build_config {
  my $self = shift;

  my $name = $self->name or croak "name must be specified to load config!";
  my $path = $self->path or croak "path must be specified to load config!";

  my $config = Config::ZOMG->open(
    name => $name,
    path => $path,
  );

  my %fallbacks = ( ROOT => $self->path );

  return visit(
    $config,
    sub {
      ref or s{\$\{(\w+)\}}{$config->{$1} // $ENV{$1} // $fallbacks{$1}}ge;
    }
  );
}

sub reload {
  my $self = shift;
  if ($self->name && $self->path) {
    $self->_clear_config;
  }
  $self->config;
}

1;
__END__

=head1 NAME

MetaCPAN::Role::Config - Configuration loader internals for MetaCPAN

=cut

