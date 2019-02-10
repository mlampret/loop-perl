package Loop::Account;

use Mojo::Base -base;
use Loop::Account::Positions;

has _balance  => 0;
has init_balance => 0;
has positions => sub { Loop::Account::Positions->new };
has timeline  => undef;

sub process {
    my ($self) = @_;

    my $step = $self->timeline->steps->current;

    for my $position ($self->positions->opened->all) {        
        $position->process( $step );
    }
}

sub balance {
    return $_[0]->_balance;
}

sub total_balance {
    my ($self) = @_;
    
    my $total = $self->balance;
    
    for my $position ($self->positions->opened->all) {
        if ($position->is_open) {
            $total += $position->current->amount;
        }
    }
    
    return $total;
}

sub debit {
    my ($self, $amount) = @_;

    unless ($self->_balance >= $amount) {
        warn "Not enough balance (required $amount, avalale ".$self->_balance.")";
        return 0;
    }
    
    $self->_balance( $self->_balance - $amount );

    return $amount;
}

sub credit {
    my ($self, $amount) = @_;

    $self->_balance( $self->_balance + $amount );

    return 0;
}

sub init_credit {
    my ($self, $amount) = @_;

    $self->init_balance( $amount );
    $self->credit( $amount );
}

sub performance {
    my ($self) = @_;
    
    return 1 unless $self->init_balance;
    return $self->total_balance / $self->init_balance;
}

1;
