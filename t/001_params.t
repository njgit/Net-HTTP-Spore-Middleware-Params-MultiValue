#!/usr/bin/perl
use Test::More;
use MIME::Base64;

use Try::Tiny;
use Data::Dumper;
use Net::HTTP::Spore;

my $mock_server = {
    '/show' => sub {
        my $req  = shift;
        #my $auth = $req->header('Authorization');
        my $pass = 0;
        if ( $req->env->{'spore.params'}->[1] eq 'me' and $req->env->{'spore.params'}->[3] eq 'you' ) {
          $pass =1;    
        }
        if ($pass) {
            $req->new_response( 200, [ 'Content-Type' => 'text/plain' ], 'ok' );
        }
        else {
            $req->new_response( 403, [ 'Content-Type' => 'text/plain' ],
                'not ok' );
        }
    },
};

#
my @tests = (
    {
        middlewares => [ [ 'Mock', tests => $mock_server ] ],
        expected => { status => 403, body => 'not ok' }
    },
    {
        middlewares => [
            [ 'Params::MultiValue' ],
            [ 'Mock',        tests    => $mock_server ],
        ],
        expected => { status => 200, body => 'ok' }
    },
);


plan tests => 3 * @tests;

foreach my $test (@tests) {
    ok my $client = Net::HTTP::Spore->new_from_spec(
        't/specs/api.json', base_url => 'http://localhost:5984'
      ),
      'client created';

    foreach ( @{ $test->{middlewares} } ) {
        $client->enable(@$_);
    }

    try { $res = $client->get_info( user => ['me','you']); } catch { $res = $_ };
    warn Dumper $res;
    is $res->status, $test->{expected}->{status}, 'valid HTTP status';
    is $res->body, $test->{expected}->{body},   'valid HTTP body';
}