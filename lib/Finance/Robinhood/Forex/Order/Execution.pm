package Finance::Robinhood::Forex::Order::Execution;

=encoding utf-8

=for stopwords watchlist watchlists untradable urls

=head1 NAME

Finance::Robinhood::Forex::Order::Execution - Represents a Single Forex Order
Execution

=head1 SYNOPSIS

    use Finance::Robinhood;
    my $rh = Finance::Robinhood->new;

    # TODO

=cut

our $VERSION = '0.92_002';
use Mojo::Base-base, -signatures;
use Mojo::URL;

sub _test__init {
    my $rh     = t::Utility::rh_instance(1);
    my $orders = $rh->forex_orders;
    my $order;
    while ($orders->has_next) {
        if ($orders->next->state eq 'filled') {
            $order = $orders->current;
            last;
        }
    }
    $order // skip_all('Cannot find a forex order to test against');
    my ($execution) = $order->executions;
    isa_ok($execution, __PACKAGE__);
    t::Utility::stash('ORDER',     $order);        #  Store it for later
    t::Utility::stash('EXECUTION', $execution);    #  Store it for later
}
use overload '""' => sub ($s, @) { $s->{id} }, fallback => 1;

sub _test_stringify {
    t::Utility::stash('EXECUTION') // skip_all();
    like(+t::Utility::stash('EXECUTION'),
         qr'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'i
    );
}
#
has _rh => undef => weak => 1;
has ['effective_price', 'id', 'quantity'];

=head1 METHODS
 
=head2 C<effective_price( )>

Returns a dollar amount.

=head2 C<id( )>

Returns a UUID.

=head2 C<quantity( )>

Returns the amount of currency.

=cut

=head2 C<timestamp( )>

Returns a Time::Moment object.

=cut

sub timestamp ($s) {
    Time::Moment->from_string($s->{timestamp});
}

sub _test_timestamp {
    t::Utility::stash('EXECUTION')
        // skip_all('No order execution object in stash');
    isa_ok(t::Utility::stash('EXECUTION')->timestamp, 'Time::Moment');
}

=head1 LEGAL

This is a simple wrapper around the API used in the official apps. The author
provides no investment, legal, or tax advice and is not responsible for any
damages incurred while using this software. This software is not affiliated
with Robinhood Financial LLC in any way.

For Robinhood's terms and disclosures, please see their website at
https://robinhood.com/legal/

=head1 LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under
the terms found in the Artistic License 2. Other copyrights, terms, and
conditions may apply to data transmitted through this module. Please refer to
the L<LEGAL> section.

=head1 AUTHOR

Sanko Robinson E<lt>sanko@cpan.orgE<gt>

=cut

1;
