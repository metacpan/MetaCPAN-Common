use strict;
use warnings FATAL => 'all';
use 5.006;

my %META = (
  name    => 'MetaCPAN-Common',
  author  => 'Graham Knop <haarg@haarg.org>',
  license => ['perl_5'],
  prereqs => {
    configure => {
      requires => {
        'ExtUtils::MakeMaker' => 0,
      },
    },
    test => {
      requires => {
        'Test::More' => '0.88',
      },
    },
    runtime => {
      requires => {
        'Config::General'             => '2.65',
        'Config::ZOMG'                => '1.000000',
        'Crypt::URandom'              => '0.39',
        'Log::Any'                    => '1.717',
        'Log::Any::Adapter::Log4perl' => '0.09',
        'Log::Contextual'             => '0.008001',
        'Log::Log4perl'               => '1.57',
        'Math::Random::ISAAC::XS'     => '1.004',
        'Moo'                         => '2.005005',
        'Moo::Role'                   => '2.005005',
        'Moose::Role'                 => '2.2207',
        'Plack'                       => '1.0051',
        'Ref::Util'                   => '0.204',
        'namespace::clean'            => '0.27',
      },
    },
    develop => {
      requires => {},
    },
  },
  resources => {
    repository => {
      url  => 'https://github.com/metacpan/MetaCPAN-Common.git',
      web  => 'https://github.com/metacpan/MetaCPAN-Common',
      type => 'git',
    },
    bugtracker => {
      web => 'https://github.com/metacpan/MetaCPAN-Common/issues',
    },
    license => ['http://dev.perl.org/licenses/'],
  },
  no_index => {
    directory => [ 't', 'xt' ]
  },
  x_breaks => {},
);

my %MM_ARGS = ();

## BOILERPLATE ###############################################################
require ExtUtils::MakeMaker;

# ( do './maint/Makefile.PL.include' or die $@ ) unless -f 'META.yml';

# have to do this since old EUMM dev releases miss the eval $VERSION line
my $eumm_version = $ExtUtils::MakeMaker::VERSION;
$eumm_version =~ tr/_//d;
my $mymeta        = $eumm_version >= 6.57_02;
my $mymeta_broken = $mymeta && $eumm_version < 6.57_07;

( $MM_ARGS{NAME} = $META{name} ) =~ s/-/::/g
  if !$MM_ARGS{NAME};
( $MM_ARGS{VERSION_FROM} = "lib/$MM_ARGS{NAME}.pm" ) =~ s{::}{/}g
  if !$MM_ARGS{VERSION} && $MM_ARGS{VERSION_FROM};
$MM_ARGS{ABSTRACT_FROM} ||= $MM_ARGS{VERSION_FROM}
  if !$MM_ARGS{ABSTRACT};
$MM_ARGS{AUTHOR} ||= $META{author};
$MM_ARGS{AUTHOR} = join ', ', @{ $MM_ARGS{AUTHOR} }
  if $eumm_version < 6.5702 && $MM_ARGS{AUTHOR};
$MM_ARGS{LICENSE} = $META{license}[0]
  if $META{license} && $eumm_version >= 6.30;
$MM_ARGS{NO_MYMETA} = 1
  if $mymeta_broken;
$MM_ARGS{META_ADD} = { 'meta-spec' => { version => 2 }, %META }
  unless -f 'META.yml';
$MM_ARGS{PL_FILES} ||= {};
$MM_ARGS{NORECURS} = 1
  if not exists $MM_ARGS{NORECURS};

for (qw(configure build test runtime)) {
  my $key = $_ eq 'runtime' ? 'PREREQ_PM' : uc $_ . '_REQUIRES';
  my $r   = $MM_ARGS{$key} = {
    %{ $META{prereqs}{$_}{requires} || {} },
    %{ delete $MM_ARGS{$key} || {} },
  };
  defined $r->{$_} or delete $r->{$_} for keys %$r;
}

$MM_ARGS{MIN_PERL_VERSION} = delete $MM_ARGS{PREREQ_PM}{perl} || 0;

delete $MM_ARGS{MIN_PERL_VERSION}
  if $eumm_version < 6.47_01;
$MM_ARGS{BUILD_REQUIRES}
  = { %{ $MM_ARGS{BUILD_REQUIRES} }, %{ delete $MM_ARGS{TEST_REQUIRES} } }
  if $eumm_version < 6.63_03;
$MM_ARGS{PREREQ_PM}
  = { %{ $MM_ARGS{PREREQ_PM} }, %{ delete $MM_ARGS{BUILD_REQUIRES} } }
  if $eumm_version < 6.55_01;
delete $MM_ARGS{CONFIGURE_REQUIRES}
  if $eumm_version < 6.51_03;

ExtUtils::MakeMaker::WriteMakefile(%MM_ARGS);
## END BOILERPLATE ###########################################################
