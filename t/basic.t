use strict;
use warnings;
use Test::More;

use Catalyst::Plugin::MetaCPAN::Config;
use Catalyst::Plugin::MetaCPAN::Fastly;
use Plack::Middleware::MetaCPAN::ReverseProxy;
use Plack::Middleware::MetaCPAN::L4PContext;
use Plack::Middleware::MetaCPAN::CSP;
use MetaCPAN::Role::Middleware;
use MetaCPAN::Common;
use MetaCPAN::Logger;
use MetaCPAN::Logger::WarnHandler;
use MetaCPAN::Config;
use MetaCPAN::Config::Log4perl;
use MetaCPAN::CSP;
use MetaCPAN::SurrogateKeys;

ok 1, 'loaded all modules';

done_testing;
