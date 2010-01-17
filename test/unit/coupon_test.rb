require File.dirname(__FILE__) + '/../test_helper'

class CouponTest < Test::Unit::TestCase
  fixtures :coupons, :currencies, :regional_prices

  def setup
    r = regional_prices(:euro)
    r.container = coupons(:first)
    r.save
  end

  def test_lookup_regional_price
    c = coupons(:first)
    
    assert_equal regional_prices(:euro).amount, c.lookup_amount('EUR').amount, "Normal lookup"
    assert_equal c.amount, c.lookup_amount($STORE_PREFS['default_currency']['code']||'USD').amount, "Default lookup"
    assert_equal c.amount / currencies(:ausdollars).rate, c.lookup_amount('AUD').amount, "Lookup with auto conversion"
    
  end
  
end
