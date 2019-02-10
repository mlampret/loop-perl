package Loop::Timeline;
use Mojo::Base -base;

use Loop::Timeline::Steps;

has steps => sub { Loop::Timeline::Steps->new };

sub performance {
    my ($self, $track) = @_;

    my $first = $self->steps->first;
    my $current = $self->steps->current;

    return $current->data->get( $track ) / $first->data->get( $track );
}

1;

