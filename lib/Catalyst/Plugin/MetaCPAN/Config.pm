package Catalyst::Plugin::MetaCPAN::Config;

use Moose::Role;

use MetaCPAN::Config;

use namespace::clean;

sub config_loader {
  my $self              = shift;
  my $class             = ref $self || $self;
  my $config_loader_ref = do {
    no strict 'refs';
    \${ $class . '::' . '_metacpan_config_loader' };
  };
  return $$config_loader_ref
    if defined $$config_loader_ref;
  $$config_loader_ref = MetaCPAN::Config->new(
    name => $class,
    path => $self->home,
  );
}

before setup => sub {
  my $self   = shift;
  my $loader = $self->config_loader;
  $self->config( {
    disable_component_resolution_regex_fallback => 1,
    ignore_frontend_proxy                       => 1,
  } );
  $self->config( $loader->config );
  $loader->init_logger;
  $self->log( Log::Log4perl::Catalyst->new( undef, autoflush => 1 ) );
};

around setup_log => sub { };

sub debug { ( $ENV{PLACK_ENV} // '' ) eq 'development' }

1;
__END__

=head1 NAME

Catalyst::Plugin::MetaCPAN::Config - Load MetaCPAN::Config as Catalyst config

=head1 DESCRIPTION

This module uses MetaCPAN::Config to configure a Catalyst application. Similar
to L<Catalyst::Plugin::ConfigLoader>.
