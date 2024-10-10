package MetaCPAN::Logger::WarnHandler;
use strict;
use warnings;

our $VERSION = 'v1.0.1';

use Log::Log4perl ();

use namespace::clean;

Log::Log4perl->wrapper_register(__PACKAGE__);

my $logger;

sub _warn_handler {
  local $@;
  if ( $logger ||= eval { Log::Log4perl->get_logger } ) {
    $logger->warn(@_);
  }
  else {
    warn @_;
  }
}

sub import {
  $SIG{__WARN__} = \&_warn_handler;
}

1;
__END__

=head1 NAME

MetaCPAN::Logger::WarnHandler - __WARN__ handler logging via Log::Log4perl

=cut
