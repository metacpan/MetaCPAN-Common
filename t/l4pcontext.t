use strict;
use warnings;

use Test::More;
use Data::Dumper ();
use Plack::Middleware::MetaCPAN::L4PContext;
use HTTP::Request::Common qw(GET);
use Log::Log4perl::MDC    ();
use Plack::Test           qw(test_psgi);

my $dumper_app = sub {
  my $content = do {
    local $Data::Dumper::Terse    = 1;
    local $Data::Dumper::Useqq    = 1;
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent   = 1;
    Data::Dumper::Dumper( Log::Log4perl::MDC->get_context );
  };
  [ 200, [], [$content] ];
};

subtest 'L4PContext default options' => sub {
  my $app = Plack::Middleware::MetaCPAN::L4PContext->wrap($dumper_app);

  test_psgi $app, sub {
    my $cb   = shift;
    my $res  = $cb->( GET "/" );
    my $data = eval $res->content;    ## no critic (BuiltinFunctions::ProhibitStringyEval)
    is_deeply $data, {
      method => 'GET',
      url    => '/',
      ip     => '127.0.0.1',
    };
  };
};

done_testing;
