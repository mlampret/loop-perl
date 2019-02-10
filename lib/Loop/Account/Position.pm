package Loop::Account::Position;

use Mojo::Base -base;

package pos_details {
    use Mojo::Base -base;
    has amount => undef;
    has ratio  => undef;
    has value  => undef;
    has step   => undef;
};

has track    => undef;
has type     => undef; # buy/sell
has opened   => sub { pos_details->new };
has closed   => sub { pos_details->new };
has current  => sub { pos_details->new };
has tp       => undef;
has sl       => undef;
has trail_sl => undef;
has account  => undef;

has _trail_sl_diff => undef;
has _trail_tp_diff => undef;

sub is_open {
    return $_[0]->closed->step ? 0 : 1;
}

sub is_closed {
    return ! $_[0]->is_open;
}

sub is_buy {
    return 1 if $_[0]->type eq 'buy';
}

sub is_sell {
    return 1 if $_[0]->type eq 'sell';
}

sub open {
    my ($self, $step, $open_amount) = @_;
    
    my $amount = $self->account->debit( $open_amount );
    
    unless ($amount) {
        warn "Unable to debit $open_amount";
        return;
    }
    
    $self->opened->step( $step );
    $self->opened->value( $step->data->get( $self->track ) );
    $self->opened->ratio( 1 );
    $self->opened->amount( $amount );
    
    for my $attr (qw/ amount value ratio step /) {
        $self->current->$attr( $self->opened->$attr );
    }
    
    if ($self->trail_sl) {
        $self->_trail_sl_diff( $self->sl - $self->current->value );
    }
        
    $self->account->positions->opened->add( $self );
}

sub close {
    my ($self, $step) = @_;
    
    return if $self->is_closed;

    $self->closed->step( $step );

    $self->closed->value( $step->data->get( $self->track ) );

    $self->closed->ratio(
        $self->is_buy
            ? $self->closed->value / $self->opened->value
            : $self->opened->value / $self->closed->value
    );

    $self->closed->amount(
        $self->opened->amount * $self->closed->ratio
    );
    
    $self->account->credit( $self->closed->amount );
}

sub process {
    my ($self, $step) = @_;

    return if $self->is_closed;

    # update current    
    $self->current->step( $step );
    $self->current->value( $step->data->get( $self->track ) );

    $self->current->ratio(
        $self->is_buy
            ? $self->current->value / $self->opened->value
            : $self->opened->value / $self->current->value
    );

    $self->current->amount(
        $self->opened->amount * $self->current->ratio
    );
    
    my $curr_val = $self->current->value;

    # close if necessary
    $self->close( $step ) if $self->is_buy  && $self->sl >= $curr_val;
    $self->close( $step ) if $self->is_buy  && $self->tp <= $curr_val;
    $self->close( $step ) if $self->is_sell && $self->sl <= $curr_val;
    $self->close( $step ) if $self->is_sell && $self->tp >= $curr_val;

    # update trailing stop loss
    if ($self->trail_sl && ! $self->is_closed) {
        my $new_sl = $self->current->value + $self->_trail_sl_diff;
        if ($self->is_buy && $new_sl > $self->sl) {
            #print "OLD SL: ".$self->sl."  ";
            $self->sl( $self->current->value + $self->_trail_sl_diff );
            #print "NEW SL: ".$self->sl."\n";
        }
    }
}

1;
