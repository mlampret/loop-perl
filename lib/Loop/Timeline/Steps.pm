package Loop::Timeline::Steps;

use Mojo::Base 'Loop::Collection';

has current => undef;


sub track {
    my ($self, $track, $data) = @_;

    return defined $data
        ? $self->_set_track( $track, $data )
        : $self->_get_track( $track );
}

sub _get_track {
    my ($self, $track) = @_;

    my @data;

    for my $step ($self->all) {
        push @data, $step->data->get( $track );
    }

    return \@data;
}

sub _set_track {
    my ($self, $track, $data) = @_;

    for my $step ($self->all) {
        $step->data->set( $track, shift @$data );
    }
}

1;