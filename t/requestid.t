use strict;
use warnings;

use Test::More;
use Data::Dumper ();
use Plack::Middleware::MetaCPAN::RequestID;
use HTTP::Request::Common qw(GET);
use Plack::Test           qw(test_psgi);

my $app = sub {
  my $env = shift;
  [ 200, [], [ $env->{'request-id'} ] ];
};
$app = Plack::Middleware::MetaCPAN::RequestID->wrap(
  $app,
  {
    env_key => 'request-id',
  }
);

test_psgi $app, sub {
  my $cb  = shift;
  my $res = $cb->( GET "/" );
  like $res->content, qr/\A[a-zA-Z0-9]{40}\z/, 'has a request id';
};

done_testing;
