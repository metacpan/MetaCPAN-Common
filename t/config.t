use strict;
use warnings;
use Test::More;

use MetaCPAN::Config;
use MetaCPAN::Config::Log4perl;

my $config = MetaCPAN::Config->new(
  path => 'corpus',
  name => 'MetaCPAN',
);

is_deeply(
  $config->config,
  {
    "View::Xslate" => {
      cache     => 1,
      cache_dir => "var/tmp/templates",
    },
    log4perl_file => "log4perl.conf",
    name          => "MetaCPAN",
  },
  'config is correct'
);

is_deeply(
  $config->log_config->config,
  {
    log4perl => {
      appender => {
        OUTPUT => {
          layout => {
            ConversionPattern => {
              value => "[%d] [%p] [%X{url}] %m%n",
            },
            value => "PatternLayout",
          },
          stderr => {
            value => 1,
          },
          value => "Log::Log4perl::Appender::Screen",
        },
      },
      rootLogger => {
        value => "DEBUG, OUTPUT",
      },
    },
  },
  'Log4perl config is correct'
);

my $nested_log = MetaCPAN::Config::Log4perl->new(
  path => 'corpus',
  name => 'log4perl_nested',
);

is_deeply(
  $nested_log->config,
  {
    log4perl => {
      appender => {
        OUTPUT => {
          layout => {
            ConversionPattern => {
              value => "[%d] [%p] [%X{url}] %m%n",
            },
            value => "PatternLayout",
          },
          stderr => {
            value => 1,
          },
          value => "Log::Log4perl::Appender::Screen",
        },
      },
      rootLogger => {
        value => "DEBUG, OUTPUT",
      },
    },
  },
  'Nested Log4perl config is correct'
);

done_testing;
