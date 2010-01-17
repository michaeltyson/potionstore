require 'test_helper'

class RegionalPriceTest < ActiveSupport::TestCase
  fixtures :products, :currencies, :regional_prices
  
  def setup
    @product = products(:first)
    r = regional_prices(:euro)
    r.container = @product
    r.save
    @def_currency = $STORE_PREFS['default_currency']['code']
    $STORE_PREFS['default_currency']['code'] = 'USD'
  end
  
  def teardown
    $STORE_PREFS['default_currency']['code'] = @def_currency
  end
  
  def test_default
    p = RegionalPrice.default_with_amount(4.99)
    assert_equal 4.99, p.amount
    assert_equal Currency.default.code, p.currency.code
  end
  
  
  def test_lookup_default
    p = RegionalPrice.lookup(@product, :default, 9.99)
    
    assert_equal 9.99, p.amount
    assert_equal 'USD', p.currency.code
    
    p = RegionalPrice.lookup(@product, 'USD', 9.99)
    
    assert_equal 9.99, p.amount
    assert_equal 'USD', p.currency.code
  end
  
  def test_lookup
    p = RegionalPrice.lookup(@product, 'EUR', 9.99)
    
    assert_equal 'EUR', p.currency.code
    assert_equal 4.99, p.amount
    assert_equal '€4.99', p.formatted_amount
    
    p = RegionalPrice.lookup(@product, Currency.lookup('EUR'), 9.99)
    
    assert_equal 'EUR', p.currency.code
    assert_equal 4.99, p.amount
    assert_equal '€4.99', p.formatted_amount
  end

  
  def test_auto_convert_amount
    p = RegionalPrice.lookup(@product, 'AUD', 9.99)
    
    assert_equal '$12.49', p.formatted_amount
  end
  
end
