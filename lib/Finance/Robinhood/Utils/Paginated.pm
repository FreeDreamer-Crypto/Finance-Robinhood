package Finance::Robinhood::Utils::Paginated;

=encoding utf-8

=head1 NAME

Finance::Robinhood::Utils::Paginated - Represent paginated data in an iterative
object

=head1 SYNOPSIS

    use Finance::Robinhood;

    my $rh = Finance::Robinhood->new();

    my $instruments = $rh->instruments();

    while(my $instrument = $instruments->next()) {
        # Do something fun here
    }

=cut

use Moo;
use MooX::HandlesVia;
our $VERSION = '0.90_001';
use Finance::Robinhood::Utils::Client;

=head1 METHODS

Some data returned by Robinhood's API is so exhaustive that it is broken up
into pages.

This class wraps that data in a friendly way.

=cut
has '_count'   => ( is => 'rw', predicate => 1 );
has '_results' => ( is => 'rw', predicate => 1 );
has '_next'    => (
    is       => 'rw',
    init_arg => 'next',
    coerce   => sub {
        ref $_[0] ? $_[0] : [ $_[0] ];
    },
    handles_via => 'Array',
    handles     => {
        mixup_next  => 'shuffle',
        unique_next => 'uniq',
        all_next    => 'elements',
        _next_page  => 'shift',
        _has_next   => 'count',
        _queue_next => 'push'
    }
);
has '_previous' => ( is => 'rw', init_arg => 'previous', predicate => 1, clearer => 1 );
has '_class' => ( is => 'ro', init_arg => 'class', predicate => 1 );

=head2 C<next( )>

    while (my $record = $paginator->next()) { ... }

Returns the next record in the current page. If all records have been exhausted
then the next page will automatically be loaded. This way if you want to ignore
pagination you can just call C<next( )> over and over again to walk through all
the records.

When we're out of pages and items, an undefined value is returned.

=cut

sub next {
    my ($s) = @_;
    my $records = $s->_results();
    return shift(@$records) if $records && scalar @$records;
    my ( $status, $data ) = $s->next_page('with_status');
    return $data if defined $status && $status != 200;
    $records = $s->_results();
    return shift(@$records) if $records && scalar @$records;
    return $data;
}

=head2 C<next_page( )>

    while (my $records = $paginator->next_page()) { ... }

Returns an array ref of records for the next page.

=cut

sub next_page {
    my ( $s, $with_status ) = @_;
    return if !$s->_has_next();
    my $page = $s->_next_page();
    my ( $status, $data ) = Finance::Robinhood::Utils::Client->instance->get($page);

    #warn $data->{next} // 'No next!';
    if ( !$data || !$data->{next} || $data->{next} eq $page ) {

        #warn 'NEXT is current!';
    }
    else { $s->_queue_next( $data->{next} ); $s->_previous( $data->{previous} ) }
    $s->_count( $data->{count} ) if $data->{count};
    $data->{results} = [ map { $_ = $_ ? $s->_class->new($_) : $_ } @{ $data->{results} } ]
        if $s->_has_class;
    $s->_results( $data->{results} );
    $with_status ? ( $status, $data->{results} ) :
        wantarray ? @{ $data->{results} } :
        $data->{results};
}

=head2 C<all( )>

    my $records = $paginator->all();

This rolls through every page building one giant array ref of all records.

=cut

sub all {
    my ($s) = @_;
    my @records = $s->_has_results() ? $s->_results() : ();
    while ( my $items = $s->next_page() ) {
        push @records, @$items;
    }
    return wantarray ? @records : \@records;
}
1;
