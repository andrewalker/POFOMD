#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Catalyst::Test 'POFOMD';

ok( action_redirect('/'), 'Request should redirect' );

done_testing();
