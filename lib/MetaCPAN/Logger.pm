package MetaCPAN::Logger;

use strict;
use warnings;
use Log::Log4perl        ();
use Log::Log4perl::Level ();

use parent 'Log::Contextual';

Log::Log4perl->wrapper_register(__PACKAGE__);

# start with debug output, since users should be setting up Log4perl
Log::Log4perl->easy_init( Log::Log4perl::Level::to_priority('DEBUG') )
  unless Log::Log4perl->initialized;

sub arg_default_logger { $_[1] || Log::Log4perl->get_logger }
sub default_import     {qw(:log :dlog)}

1;
