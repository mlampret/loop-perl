package Loop::App;

use Data::Dumper;
use Mojo::Base -base;
use Mojo::Util qw/ camelize /;

use Loop::Account;
use Loop::Loader;
use Loop::Strategy::Default;
use Loop::Timeline;
use Loop::Timeline::Step;

has account  => sub { Loop::Account->new };
has loader   => sub { Loop::Loader->new };
has timeline => sub { Loop::Timeline->new };
has strategy => undef;

sub run {
    my ($self) = shift;

    $self->loader->timeline( $self->timeline );
    $self->account->timeline( $self->timeline );
    
    my $strategy_name = camelize( $ARGV[0] // 'default' );
    my $strategy = undef;
    eval "use Loop::Strategy::$strategy_name; \$strategy = Loop::Strategy::$strategy_name->new();";
    $strategy->app( $self );

    $self->strategy( $strategy );

    for my $requirement ($self->strategy->required->all) {
        $self->loader->load( $requirement );
    }

    $self->account->init_credit( 1_0000 );
    $self->strategy->before_start;

    say $self->status;
    
    for my $step ($self->timeline->steps->all) {

        $self->timeline->steps->current( $step );

        say $self->status if $step->id % 100 == 0;
        
        $self->account->process;

        $self->strategy->process;
    }

    say $self->status;

    $self->strategy->after_end;
}

sub status {
    my ($self) = @_;
    
    my $step = $self->timeline->steps->current;
    
    return join "\t", (
        "Step: " . $step->id . ' / ' . $self->timeline->steps->count,
        $step->name,
        (
            join "\t",
                map {
                    "$_ "
                    . sprintf(' %.2f', $step->data->get( $_ // 0) )
                    .(	$_ =~ m/-/
                        ? ''
                        : "\t mPerf: " . sprintf('%.2f', $self->timeline->performance( $_ ) )
                    )
                }
                sort $step->data->tracks
        ),
        "Balance: "
            . sprintf('%.2f', $self->account->balance) . ' / '
            . sprintf('%.2f', $self->account->total_balance)
            . "\t pPerf: "
            . sprintf('%.2f', $self->account->performance),
#        "oPerf: "
#            . sprintf('%.2f', $self->account->performance / $self->timeline->performance)
    );
}

1;
