use strict;
use warnings;

use Test::More;
use Data::Dumper ();
use Digest::SHA ();
use Plack::Middleware::MetaCPAN::CSP;
use HTTP::Request::Common qw(GET);
use Plack::Test           qw(test_psgi);

my $make_app = sub {
  my $cb = shift;
  sub {
    my $env = shift;
    [ 200, [], [ $cb->($env) ] ];
  };
};

subtest 'CSP middleware' => sub {
  my $app = Plack::Middleware::MetaCPAN::CSP->wrap($make_app->(sub {
    my $env = shift;
    my $body = '';
    my $script_nonce = $env->{'csp.nonce_for'}->('script-src');
    $body .= qq[<script nonce="$script_nonce">alert("guff")</script>];
    my $script_content = "alert('welp')";
    my $script_digest = $env->{'csp.sha_for'}->('script-src', $script_content);
    $body .= qq[<script id="digest">$script_content</script>];
    $env->{'csp.add'}->('img-src', 'data:');
    $body;
  }));

  test_psgi $app, sub {
    my $cb   = shift;
    my $res  = $cb->( GET "/" );
    my $content = $res->content;
    my $csp = $res->header('Content-Security-Policy');
    my %csp = map split(/ /, $_, 2), split /; /, $csp;
    my ($script_nonce) = $content =~ /<script nonce="([^"]+)">/;
    my ($script_content) = $content =~ m{<script id="digest">([^<]+)</script>};
    my $sha = Digest::SHA::sha256_base64($script_content);
    like $csp{'script-src'}, qr/'nonce-$script_nonce'/,
      'nonce added to headers';
    like $csp{'script-src'}, qr/'sha256-$sha=*'/,
      'digest added to headers';
    like $csp{'img-src'}, qr/data:/,
      'data: added to headers';
  };
};

done_testing;
