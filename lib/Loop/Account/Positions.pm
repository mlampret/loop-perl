package Loop::Account::Positions;

use Mojo::Base -base;

has opened => sub { Loop::Collection->new };
has closed => sub { Loop::Collection->new };

1;