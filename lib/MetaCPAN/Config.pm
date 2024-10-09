package MetaCPAN::Config;
use strict;
use warnings;

our $VERSION = 'v1.0.1';

use Moo;

use Carp            qw(cluck croak);
use Module::Runtime qw(require_module);

use namespace::clean;

with 'MetaCPAN::Role::Config';

has log_config_class => (
  is => 'ro',
  default => 'MetaCPAN::Config::Log4perl',
);

has log_config => (
  is      => 'lazy',
  default => sub {
    my $self = shift;

    my $opts = {
      path => $self->path,
    };

    if (my $l4p_config = $self->config->{log4perl}) {
      if (!is_plain_hashref($l4p_config)) {
        croak "log4perl value must be a hash ref, not a $l4p_config!";
      }
      elsif (grep !/\Alog4perl(?:\.|\z)/, keys %$l4p_config) {
        $opts->{config} = {
          log4perl => $l4p_config,
        };
      }
      else {
        $opts->{config} = $l4p_config;
      }
    }
    elsif (my $name = $self->config->{log4perl_file}) {
      if ( $name =~ m{/} ) {
        cluck(
          "Ignoring log4perl_file config '$name' in different directory!");
      }
      else {
        $opts->{name} = $name =~ s{\.[^.]+\z}{}r;
      }
    }

    my $log_class = $self->log_config_class;
    require_module($log_class);
    $log_class->new($opts);
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
