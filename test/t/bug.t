# vi:filetype=perl

use lib 'lib';
use Test::Nginx::Socket; # 'no_plan';

plan tests => 11;

no_diff;

run_tests();

__DATA__

=== TEST 1: set Server
--- config
    #more_set_headers 'Last-Modified: x';
    more_clear_headers 'Last-Modified';
--- request
    GET /index.html
--- response_headers
! Last-Modified
--- response_body_like: It works!



=== TEST 2: variables in the Ranges header
--- config
    location /index.html {
        set $rfrom 1;
        set $rto 3;
        more_set_input_headers 'Range: bytes=$rfrom - $rto';
        #more_set_input_headers 'Range: bytes=1 - 3';
        #echo $http_range;
    }
--- request
GET /index.html
--- error_code: 206
--- response_body chomp
htm



=== TEST 3: mime type overriding (inlined types)
--- config
    more_clear_headers 'X-Powered-By' 'X-Runtime' 'ETag';

    types {
        text/html                             html htm shtml;
        text/css                              css;
    }
--- user_files
>>> a.css
hello
--- request
GET /a.css
--- error_code: 200
--- response_headers
Content-Type: text/css
--- response_body
hello



=== TEST 4: mime type overriding (included types file)
--- config
    more_clear_headers 'X-Powered-By' 'X-Runtime' 'ETag';
    include mime.types;
--- user_files
>>> a.css
hello
>>> ../conf/mime.types
types {
    text/html                             html htm shtml;
    text/css                              css;
}
--- request
GET /a.css
--- error_code: 200
--- response_headers
Content-Type: text/css
--- response_body
hello

