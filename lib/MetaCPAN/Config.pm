package MetaCPAN::Config;
use strict;
use warnings;

our $VERSION = 'v1.0.0';

use Moo;

use Config::ZOMG;
use Ref::Util qw(
  is_plain_arrayref
  is_plain_hashref
);
use File::Spec::Functions qw(rel2abs);
use Log::Log4perl         ();
use Carp                  ();

use namespace::clean;

has name => (
  is       => 'ro',
  required => 1,
);
has path => (
  is       => 'ro',
  required => 1,
  coerce   => sub { rel2abs( $_[0] ) },
);

has config => (
  is      => 'ro',
  lazy    => 1,
  builder => 1,
  clearer => '_clear_config',
);

sub _build_config {
  my $self = shift;

  my $config = Config::ZOMG->open(
    name => $self->name,
    path => $self->path,
  );

  my %fallbacks = ( ROOT => $self->path, );

  _visit(
    $config,
    sub {
      s{\$\{(\w+)\}}{$config->{$1} // $ENV{$1} // $fallbacks{$1}}ge;
    }
  );
  return $config;
}

sub reload {
  my $self = shift;
  $self->_clear_config;
  $self->config;
}

sub _visit {
  my ( $config, $cb ) = @_;
  my $new_config;
  my @queue = [ [], $config, \$new_config ];
  while (@queue) {
    my ( $path, $item, $new ) = @{ +shift @queue };
    if ( is_plain_hashref($item) ) {
      $$new = {};
      for my $key ( keys %$item ) {
        my $value = $item->{$key};
        push @queue, [ [ @$path, $key ], $value, \$$new->{$key} ];
      }
    }
    elsif ( is_plain_hashref($item) ) {
      $$new = [];
      for my $i ( 0 .. $#$item ) {
        my $value = $item->[$i];
        push @queue, [ [ @$path, $i ], $value, \$$new->[$i] ];
      }
    }
    else {
      $$new = $item;
      for ($$new) {
        $cb->($path);
      }
    }
  }
  return $new_config;
}

has log_config => (
  is      => 'lazy',
  default => sub {
    my $self = shift;

    my $opts = { path => $self->path };

    my $name = $self->config->{log4perl_file};
    if ( defined $name ) {
      if ( $name =~ m{/} ) {
        Carp::cluck(
          "Ignoring log4perl_file config '$name' in different directory!");
      }
      else {
        $opts->{name} = $name =~ s{\.[^.]+\z}{}r;
      }
    }

    require MetaCPAN::Config::Log4perl;
    MetaCPAN::Config::Log4perl->new($opts);
  },
  clearer => '_clear_log_config',
);

after _clear_config => sub {
  my $self = shift;
  $self->_clear_log_config;
};

sub init_logger {
  my $self = shift;
  $self->log_config->init;
}

1;
__END__

=head1 NAME

MetaCPAN::Config - Configuration loader for MetaCPAN

=cut
