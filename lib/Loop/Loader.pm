package Loop::Loader;

use Mojo::Base -base;

use Loop::Derivative;
use Loop::Timeline::Step;

has timeline => sub { die "timeline must be set at creation time" };

sub load {
    my ($self, $requirement) = @_;

    if ($requirement->{data}) {
        $self->load_file( $requirement->{data} );
    }
    elsif ($requirement->{derivative}) {
        $self->derive( $requirement );
    }
}

sub derive {
    my ($self, $requirement) = @_;

    my $track  = $requirement->{track};
    my $class  = $requirement->{derivative}{class};
    my $params = $requirement->{derivative}{params};

    my $d = undef;

    eval "use Loop::Derivative::$class; \$d = Loop::Derivative::$class->new";

    $d->timeline( $self->timeline );

    $d->load( $track, @$params );

    return $d;
}

sub load_file {
    my ($self, $track) = @_;
    
    my $id = 1;
    my $prev = undef;
    
    my $filepath = "./data/$track.csv";
    
    open(my $file, '<', $filepath) or die "Can't load file $filepath";    

    while (my $line = <$file>) {
        $line =~ s/\n//;

        my ($date, $val) = split /,/, $line, 2;
        $val =~ s/[,"]//g;
        
        my $step = Loop::Timeline::Step->new(id => $id++ );
        $step->name( $date );
        $step->data->set( $track, $val );
        $self->timeline->steps->add( $step );
        $step->prev( $prev );
        
        $prev->next($step) if $prev;

        $prev = $step;
    }
    close $file;

    $self->timeline->steps->current( $self->timeline->steps->first );
}

1;
