package Plack::Impl::Nginx;
use strict;
use warnings;
use nginx;
use Plack::Util;

sub nginx_handler {
    my($handler, $r) = @_;

    my %env;
    $env{'psig.version'} = [1,0];
    $env{'psig.inputs'}   = undef; # XXX tied?
    $env{'psig.errors'}   = undef; # XXX
    $env{REQUEST_METHOD} = $r->request_method;
    $env{SCRIPT_NAME}    = $r->uri;
    $env{QUERY_STRING}   = $r->args;
    $env{SERVER_NAME}    = 'nginx';

    $env{REMOTE_ADDR}    = $r->remote_addr;

    # fetch headers;
    my $max = $r->headers();
    my @headers;
    for my $c (0..($max)) {
        push @headers, $r->header_by_n($c);
    }

    for my $name (@headers) {
        next unless $name;
        my $v = $r->header_in($name);
        $name =~ s/-/_/g;
        $name = uc $name;
        $name = "HTTP_$name" unless $name eq 'CONTENT_LENGTH' || $name eq 'CONTENT_TYPE';

        $env{$name} = $v;
    }

    my $res = $handler->(\%env);
    my $content_type = 'text/html';
    while (my($k, $v) = splice @{ $res->[1] }, 0, 2) {
        if (uc $k eq 'CONTENT-TYPE') {
            $content_type = $v;
        } else {
            $r->header_out($k, $v);
        }
    }
    $r->send_http_header($content_type);

    return $res->[0] if $r->header_only;
    Plack::Util::foreach($res->[2], sub { $r->print(shift) });
    $r->rflush;

    return $res->[0];
}


1;
__END__

=head1 AUTHOR

yappo

=cut
