package MetaCPAN::Config::Log4perl;
use strict;
use warnings;

use Moo;

extends 'MetaCPAN::Config';

has '+name' => ( default => 'log4perl', );

has '+config' => ( handles => [qw(parse)], );

around _build_config => sub {
  my ( $orig, $self ) = ( shift, shift );
  my $config = $self->$orig;

  my $l4p_config = {};
  MetaCPAN::Config::_visit(
    $config,
    sub {
      my @path = split /\./, join '.', @{ +shift };
      if ( $path[-1] =~ /\A(?:_|value|)\z/ ) {
        pop @path;
      }
      my $pos = $l4p_config;
      for my $path (@path) {
        $pos = $pos->{$path} ||= {};
      }
      $pos->{value} = $_;
    }
  );
  return $l4p_config;
};

sub init {
  my $self = shift;

  require Log::Log4perl;
  Log::Log4perl->reset;
  Log::Log4perl->init( $self->config );

  require MetaCPAN::Logger::WarnHandler;
  MetaCPAN::Logger::WarnHandler->import;

  if ( $INC{'Log/Any.pm'} ) {
    require Log::Any::Adapter;
    require Log::Any::Adapter::Log4perl;
    Log::Any::Adapter->set('Log4perl');
  }
}

1;
