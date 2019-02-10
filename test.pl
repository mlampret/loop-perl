#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;

use lib './lib';
use Loop::Derivative::MovingAverage;

my $d = Loop::Derivative::MovingAverage->new;

my $array = [ (1, 1, 1, 3, 3, 3, 5, 5, 5, 5) x 1 ];

print Dumper $d->ma( 3, $array );


