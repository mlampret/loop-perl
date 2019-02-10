package Loop::Collection;

use Mojo::Base -base;

has elements => sub { [] };

sub add {
    my ($self, @elements) = @_;
    push $self->elements->@*, @elements;
    return $self;
}

sub count {
    return scalar $_[0]->elements->@*;
};

sub all {
    return $_[0]->elements->@*;
}

sub first {
    return $_[0]->elements->[0];
}

sub last {
    return $_[0]->elements->[-1];
}

sub clear {
    $_[0]->elements->@* = ();
}

1;
