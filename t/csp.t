use strict;
use warnings;
use Test::More;

use MetaCPAN::CSP;

my $csp1   = MetaCPAN::CSP->new;
my $nonce1 = $csp1->nonce_for('script-src');

is $csp1->header_value, "script-src 'nonce-$nonce1'",
  'nonce added to header properly';

done_testing;

