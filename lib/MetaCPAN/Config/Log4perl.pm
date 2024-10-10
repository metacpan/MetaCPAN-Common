package MetaCPAN::Config::Log4perl;
use strict;
use warnings;

our $VERSION = 'v1.0.1';

use Moo;
use MetaCPAN::Common qw(visit);

use namespace::clean;

with 'MetaCPAN::Role::Config';

has '+name' => ( default => 'log4perl' );

has parse => (
  is => 'lazy',
  clearer => 1,
);

after _clear_config => sub {
  my $self = shift;
  $self->_clear_parse;
};

sub _build_parse {
  my $self = shift;
  my $config = $self->config;

  my $l4p_config = {};
  visit(
    $config,
    sub {
      my $value = $_;
      return
        if ref $value;
      my @path = split /\./, join '.', @{ +shift };
      if ( $path[-1] =~ /\A(?:_|value|)\z/ ) {
        pop @path;
      }
      my $pos = $l4p_config;
      for my $path (@path) {
        $pos = $pos->{$path} ||= {};
      }
      $pos->{value} = $value;
    }
  );
  return $l4p_config->{log4perl};
}

sub init {
  my $self = shift;

  require Log::Log4perl;
  Log::Log4perl->reset;
  Log::Log4perl->init($self);

  require MetaCPAN::Logger::WarnHandler;
  MetaCPAN::Logger::WarnHandler->import;

  if ( $INC{'Log/Any.pm'} ) {
    require Log::Any::Adapter;
    require Log::Any::Adapter::Log4perl;
    Log::Any::Adapter->set('Log4perl');
  }
}

1;
__END__

=head1 NAME

MetaCPAN::Config::Log4perl - Log4perl configuration loader for MetaCPAN

=cut
