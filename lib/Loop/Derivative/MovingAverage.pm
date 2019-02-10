package Loop::Derivative::MovingAverage;

use Mojo::Base -base;

has timeline => undef;

sub load {
    my ($self, $dest_track, $source_track, $period) = @_;
    
    my $data = $self->timeline->steps->track( $source_track );
    
    my $der_data = $self->ma( $period, $data );

    $self->timeline->steps->track( $dest_track, $der_data );
}

sub ma {
    my ($self, $period, $elements) = @_;
    
    my @result = ();
    my @subset = ();
    
    my $sum = 0;
    my $cnt = 0;
    
    for my $cnt (0..scalar(@$elements) - 1) {
        $sum += $elements->[$cnt];
        my $pcnt = $cnt - $period;
        $sum -= $elements->[$pcnt] if $pcnt >= 0;

        if ($cnt + 1 >= $period) {
            push @result, $sum / $period;
        } else {
            push @result, undef;
        }
    }
 
    return \@result;
}

1;
