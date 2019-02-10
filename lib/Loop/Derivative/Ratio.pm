package Loop::Derivative::Ratio;

use Mojo::Base -base;

has timeline => undef;

sub load {
    my ($self, $dest_track, $source_track_1, $source_track_2) = @_;
 
    for my $step ( $self->timeline->steps->all ) {
        my $val1 = $step->data->get( $source_track_1 );
        my $val2 = $step->data->get( $source_track_2 );

        next unless defined( $val1 ) && defined( $val2 ) && $val2 != 0;

        $step->data->set( $dest_track, $val1 / $val2 );
    }
}

1;
