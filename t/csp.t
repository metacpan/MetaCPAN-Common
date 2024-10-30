use strict;
use warnings;
use Test::More;

use MetaCPAN::CSP;

my $csp1   = MetaCPAN::CSP->new;
my $nonce1 = $csp1->nonce_for('script-src');

is $csp1->header_value, "script-src 'nonce-$nonce1'",
  'nonce added to header properly';

my $digest = $csp1->sha_for('script-src' => 'some content');

is $csp1->header_value, "script-src 'nonce-$nonce1' 'sha256-$digest'",
  'digest added to header properly';

done_testing;

