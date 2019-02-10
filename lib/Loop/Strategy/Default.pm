package Loop::Strategy::Default;

use Mojo::Base 'Loop::Strategy';


has required => sub { Loop::Collection->new->add(
    {
        track      => 'gold_gbp',
        data       => 'gold_gbp',
        visible    => 1,
        performing => 1,
    },
)};

sub before_start {
    my ($self) = @_;
    
    my $step = $self->app->timeline->steps->current;

    my $position = Loop::Account::Position->new(
        set     => 'gold_gbp',
        type    => 'buy',
        tp	    => 10_000,
        sl      => 100,
        account => $self->app->account,
    );

    $position->open( $step, $self->app->account->init_balance / 100 * 10 );
    
}

1;