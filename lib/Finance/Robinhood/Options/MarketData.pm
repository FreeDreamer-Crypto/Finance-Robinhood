package Finance::Robinhood::Options::MarketData;
use Moo;
use Time::Moment;
#
has [
    qw[adjusted_mark_price  ask_price ask_size bid_price bid_size
        break_even_price high_price instrument last_trade_price last_trade_size
        low_price mark_price open_interest previous_close_price
        volume chance_of_profit_long chance_of_profit_short
        delta gamma rho theta vega
        implied_volatility]
] => ( is => 'ro' );
has 'previous_close_date' => (
    is     => 'ro',
    coerce => sub {
        Time::Moment->from_string( $_[0] . 'T00:00:00Z' );
    }
);
1;