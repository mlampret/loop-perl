package Loop::Strategy;

use Loop::Account::Position;
use Loop::Collection;

use Mojo::Base -base;

has app => undef;

has required => sub { Loop::Collection->new };

sub before_start { }

sub after_end { }

sub process { }

1;