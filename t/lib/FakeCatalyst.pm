package FakeCatalyst;
use strict;
use warnings;
use Plack::Response;

sub name {
  my $self = shift;
  return ref $self || $self;
}

sub home { $_[0]->config->{home} }

sub setup {
  my $class  = shift;
  my (%args) = @_;
  my $name   = $self->name;

  my $prefix = uc($name) =~ s/::/_/gr;
  my $home   = $args{home} || $ENV{"${prefix}_HOME"} || do {
    ( my $file = $class ) =~ s{::}{/}g;
    $file .= '.pm';
    my $inc = $INC{$file} =~ s{\Q$file\E\z}{}r;
    $inc =~ s{[/\\]lib[/\\]\z}{}r;
  };
  $self->config->{home} = $home;
  $self->config->{root} = "$home/root";
  return $class;
}

my %config;

sub config {
  my $self  = shift;
  my $class = ref $self || $self;

  my $config = $config{$class} ||= {};

  my %new_config = @_ == 1 ? %{ $_[0] } : @_;

  @{$config}{ keys %new_config } = values %new_config;

  return $config;
}

sub finalize         { }
sub finalize_headers { }

sub res {
  my $self = shift;
  $self->{res} ||= Plack::Response->new(200);
}

1;
