package Loop::Timeline::Step;

use Mojo::Base -base;
use Loop::Timeline::Step::Data;

has id		=> undef;
has name    => undef;
has data    => sub { Loop::Timeline::Step::Data->new };
has vectors => undef;
has prev    => undef;
has next    => undef;

1;
