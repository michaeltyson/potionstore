require File.dirname(__FILE__) + '/../test_helper'

class ProductTest < Test::Unit::TestCase
  fixtures :products, :currencies, :regional_prices

  def setup
    r = regional_prices(:euro)
    r.container = products(:first)
    r.save
  end

  def test_lookup_regional_price
    p = products(:first)
    
    assert_equal regional_prices(:euro).amount, p.lookup_price('EUR').amount
    assert_equal p.price, p.lookup_price($STORE_PREFS['default_currency']['code']||'USD').amount
    assert_equal p.price / currencies(:ausdollars).rate, p.lookup_price('AUD').amount
    
  end
end
