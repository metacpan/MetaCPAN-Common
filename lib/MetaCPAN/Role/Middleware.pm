package MetaCPAN::Role::Middleware;
use Moo::Role;

has app => ( is => 'ro' );
requires 'call';

sub wrap {
  my ( $self, $app, @args ) = @_;
  my $args = $self->BUILDARGS(@args);
  $args = {
    ( ref $self ? %$self : () ),
    app => $app,
    %$args,
  };
  return $self->new($args)->to_app;
}

sub to_app {
  my $self = shift;
  return sub { $self->call(@_) };
}

1;
