package Loop::Timeline::Step::Data;

use Mojo::Base -base;

has _values => sub { {} };

sub get {
    my ($self, $track) = @_;
    
    return $self->_values->{ $track };
}

sub set {
    my ($self, $track, $value) = @_;
    
    return $self->_values->{ $track } = $value;
}

sub tracks {
    my ($self) = @_;
    
    return keys $self->_values->%*;
}

1;
