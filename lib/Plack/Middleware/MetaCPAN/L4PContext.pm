package Plack::Middleware::MetaCPAN::L4PContext;

use Moo;

use Log::Log4perl::MDC ();

with qw(MetaCPAN::Role::Middleware);

has reset => (
  is      => 'ro',
  default => !!1,
);

sub call {
  my ( $self, $env ) = @_;
  my $mdc = Log::Log4perl::MDC->get_context;
  %$mdc = (
    ( $self->reset ? () : %$mdc ),
    ip     => $env->{REMOTE_ADDR},
    method => $env->{REMOTE_METHOD},
    url    => $env->{REQUEST_URI},
    map +(
      lc($_) =~ s/_(.)/-\u$1/gr =~ s/^http-//r => $env->{$_}
    ),
    grep /^HTTP_(?:SEC_|REFERER$)/,
    keys %$env
  );
  $self->app($env);
}

1;
