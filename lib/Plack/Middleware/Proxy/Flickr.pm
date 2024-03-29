use strict;
package Plack::Middleware::Proxy::Flickr;
BEGIN {
  $Plack::Middleware::Proxy::Flickr::AUTHORITY = 'cpan:PNU';
}
BEGIN {
  $Plack::Middleware::Proxy::Flickr::VERSION = '0.001'; # TRIAL
}
# ABSTRACT: Proxy images from Flickr

use Moose;
use Plack::Util;
use Try::Tiny;
use Carp;
use Flickr::Simple2;
use URI::Escape;
use CHI;
use Data::Dumper;

extends 'Plack::Middleware';

has 'apikey'    => (is => 'ro');
has 'apisecret' => (is => 'ro');

has 'flickr' => ( is => 'ro', lazy => 1, default => sub {
    my $self = shift;
    return Flickr::Simple2->new({
        api_key    => $self->apikey,
        api_secret => $self->apisecret
    });
} );

has 'chi' => ( is => 'ro', lazy => 1, default => sub {
    my $self = shift;
    return CHI->new(
        driver => 'Memory',
        global => 1
    );
} );

sub call {
    my ($self,$env) = @_;

    my ($photo_id,$ext) = $env->{PATH_INFO} =~ /(\d+)\.(\w+)$/;
    return $self->notfound unless $photo_id and $ext;

    my $photo = $self->chi->compute( $photo_id, sub {
        $self->flickr->get_photo_detail( $photo_id );
    } );

    if ( not defined $photo ) {
        $self->chi->remove( $photo_id );
        return $self->notfound;
    }

    my $url = # http://www.flickr.com/services/api/misc.urls.html
        'http://farm'.$photo->{farm}.'.static.flickr.com/'.$photo->{server}.
        '/'.$photo->{id}.'_'.$photo->{originalsecret}.'_o.'.$ext;

    $env->{'plack.proxy.url'} = $url;
    return $self->app->($env);
}


sub notfound {
    my $self = shift;
    return [ 404, [ 'Content-Type' => 'text/plain' ],[ 'not found' ] ];
}


1;

__END__
=pod

=head1 NAME

Plack::Middleware::Proxy::Flickr - Proxy images from Flickr

=head1 VERSION

version 0.001

=head1 SYNOPSIS

    # example1.psgi
    
    builder {
        enable 'Image::Scale', memory_limit => 50_000_000;
        enable 'Proxy::Flickr', apikey => 'xxx', apisecret => 'yyy';
        Plack::App::Proxy->new();
    };

This module is just a proof of concept. Do not use!

Request to /nnn_200x200.jpg will fetch image nnn from Flickr,
scale it to 200x200 size and convert to jpg, on the fly.

=head1 METHODS

=head2 notfound

Return 404 status to the caller.

=head1 AUTHOR

Panu Ervamaa <pnu@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Panu Ervamaa.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

