use strict;
use warnings;
requires 'perl' => 'v5.22';

requires 'CatalystX::Fastly::Role::Response' => '0.07';
requires 'Config::ZOMG'                => '1.000000';
requires 'Crypt::URandom'              => '0.39';
requires 'Log::Any'                    => '1.717';
requires 'Log::Any::Adapter::Log4perl' => '0.09';
requires 'Log::Contextual'             => '0.008001';
requires 'Log::Log4perl'               => '1.57';
requires 'Math::Random::ISAAC::XS'     => '1.004';
requires 'Moo'                         => '2.005005';
requires 'Moo::Role'                   => '2.005005';
requires 'Moose::Role'                 => '2.2207';
requires 'Plack'                       => '1.0051';
requires 'Ref::Util'                   => '0.204';
requires 'Types::Standard'             => '2.000000';
requires 'namespace::clean'            => '0.27';

test_requires 'Config::General'        => '2.65';
test_requires 'Test::More'             => '0.96';
