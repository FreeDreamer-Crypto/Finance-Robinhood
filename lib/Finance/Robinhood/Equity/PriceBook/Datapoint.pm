package Finance::Robinhood::Equity::PriceBook::Datapoint;

=encoding utf-8

=for stopwords watchlist watchlists untradable urls

=head1 NAME

Finance::Robinhood::Equity::PriceBook::Datapoint - Represents a Single price
point in a Equity Instrument's Level II Price Data

=head1 SYNOPSIS

    use Finance::Robinhood;
    my $rh = Finance::Robinhood->new->login('user', 'pass');

    # TODO

=cut

our $VERSION = '0.92_003';
use Mojo::Base-base, -signatures;
use Mojo::URL;

sub _test__init {
    my $rh = t::Utility::rh_instance(1);
    {
        my $todo = todo("I'm not a current Gold subscriber");
        my ($datapoint)
            = eval { $rh->equity_instrument_by_symbol('MSFT')->pricebook->asks };
        isa_ok($datapoint, __PACKAGE__);
        t::Utility::stash('DATAPOINT', $datapoint);    #  Store it for later
    }
}
##

=head1 METHODS

=cut

has _rh => undef => weak => 1;

=head2 C<price( )>

The current price.

=head2 C<size( )>

Total size of the orders at this price.

=cut

has ['price', 'size'];

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
