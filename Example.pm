package Example;
use strict;
use warnings;
use Plack::Impl::Nginx;
use Data::Dumper;

sub nginx_handler { Plack::Impl::Nginx::nginx_handler(\&handler, @_) }

sub handler {
    my $env = shift;

    my $body = Dumper($env);
    [200, ['Content-Type', 'text/plain', 'Content-Length', length($body), 'X-Yappo', 'Hokke'], [$body]];
}

1;
