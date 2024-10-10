package MetaCPAN::Role::Config;
use strict;
use warnings;

our $VERSION = 'v1.0.1';

{ use Moo::Role; }

use Config::ZOMG;
use File::Spec::Functions qw(rel2abs canonpath);
use Carp                  qw(croak confess);
use MetaCPAN::Common      qw(visit dpath);

use namespace::clean;

sub _find_caller {
  my $self = shift;
  my $class = ref $self || $self;
  my $c = 0;
  while (my @c = caller($c++)) {
    next
      if $c[0] eq __PACKAGE__
        || $c[0]->isa($class)
        || $c[0]->isa('Class::MOP::Mixin')
        || $c[0] =~ /\AEval::Closure::Sandbox_/;

    return @c;
  }
  return;
}

has name => (
  is       => 'ro',
);

has path => (
  is       => 'ro',
  coerce   => sub { defined $_[0] ? rel2abs( $_[0] ) : undef },
  default => sub {
    my $self = shift;
    my ($package, $file) = $self->_find_caller;

    return undef
      if !$file;

    my $lib_path
      = canonpath( join '/', '', 'lib', split /::/, $package . '.pm' );
    my $fullpath = canonpath( rel2abs($file) );
    if ( -e $file && $fullpath =~ s{\Q$lib_path\E\z}{} ) {
      $fullpath ||= '/';
      return $fullpath;
    }
    return undef;
  },
);

around BUILDARGS => sub {
  my ($orig, $self) = (shift, shift);
  if (@_ == 1) {
    my ($name) = @_;
    if (!ref $name) {
      return {
        name => $name,
      };
    }
  }
  $self->$orig(@_);
};

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
      ref or s{\$\{(\w+)\}}{dpath($config, $1) // $ENV{$1} // $fallbacks{$1}}ge;
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

