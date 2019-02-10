package Loop::Strategy::SimpleAvg;

use Mojo::Base 'Loop::Strategy';

has required => sub { Loop::Collection->new->add(
    {
        track      => 'gold_gbp',
        data 	   => 'gold_gbp',
        visible    => 1,
        performing => 1,
    },
    {
        track      => 'ma-short',
        visible    => 1,
        derivative => {
            class  => 'MovingAverage',
            params => [ 'gold_gbp', 18 ],
        },
    },
    {
        track      => 'ma-long',
        visible    => 1,
        derivative => {
            class  => 'MovingAverage',
            params => [ 'gold_gbp', 147 ],
        },
    },
    {
        track      => 'ma-ratio',
        visible    => 1,
        derivative => {
            class  => 'Ratio',
            params => [ 'ma-short', 'ma-long' ],
        },
    },
) };

sub process {
    my ($self) = @_;
    
    my $step = $self->app->timeline->steps->current;

    return unless $step->prev;

    my $r_prev = $step->prev->data->get('ma-ratio');
    my $r_curr = $step->data->get('ma-ratio');
    
    return unless $r_prev && $r_curr;
    return if $r_prev < 1 && $r_curr < 1;
    return if $r_prev > 1 && $r_curr > 1;

    my $r_diff = abs( $r_prev - $r_curr );
    return if $r_diff < 0.001;

    my $value = $step->data->get('gold_gbp');

    if ($r_prev < $r_curr) {  
    
        my $position = Loop::Account::Position->new(
            track    => 'gold_gbp',
            type     => 'buy',
            tp	     => 10_000,
            sl       => $value - ($value / 100 * 4),
            trail_sl => 0,
            account  => $self->app->account,
        );
        
        my $amount = $self->app->account->balance / 100 * 4;

        $position->open( $step, $amount );
    }
    elsif ($r_prev > $r_curr) {
        my $position = Loop::Account::Position->new(
            track    => 'gold_gbp',
            type     => 'sell',
            tp	     => 0,
            sl       => $value + ($value / 100 * 4),
            trail_sl => 0,
            account  => $self->app->account,
        );

        $position->open( $step, $self->app->account->balance / 100 * 4 );
    }
}

1;