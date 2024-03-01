package MetaCPAN::Logger::WarnHandler;
use strict;
use warnings;
use Log::Log4perl ();

Log::Log4perl->wrapper_register(__PACKAGE__);

my $logger;

sub warn_handler {
  local $@;
  if ( $logger ||= eval { Log::Log4perl->get_logger } ) {
    $logger->warn(@_);
  }
  else {
    warn @_;
  }
}

sub import {
  $SIG{__WARN__} = \&warn_handler;
}

1;
