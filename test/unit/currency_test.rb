require 'test_helper'

class CurrencyTest < ActiveSupport::TestCase
  fixtures :currencies
  
  def setup
    @orig_def_rate = $STORE_PREFS['default_currency']['rate']
    $STORE_PREFS['default_currency']['rate'] = 0.5
  end
  
  def teardown
    $STORE_PREFS['default_currency']['rate'] = @orig_def_rate
  end
  
  def test_default
    c = Currency.default
    assert_equal $STORE_PREFS['default_currency']['code'] || 'USD', c.code
    assert_equal 1.0, c.rate
  end
  
  def test_report
    c = Currency.report_currency
    assert_equal $STORE_PREFS['report_currency']['code'] || 'USD', c.code
  end
  
  def test_rate_to_report
    c = Currency.new
    c.code = 'XXX'
    c.rate = 0.5
    
    assert_equal 0.25, c.rate_to_report_currency

  end
  
  def test_default_countries_for_currency
    countries = Currency.default_countries_for_currency 'AUD'
    assert_equal ['AU','CX','CC','HM','KI','NR','NF','TV'], countries
  end
  
  def test_formatting
    c = Currency.new
    c.code = 'EUR'
    c.unit = '€'
    assert_equal '€2.99', c.format_amount(2.99)
    
    c.separator = ','
    assert_equal '€2,99', c.format_amount(2.99)
  end
  
  def test_currency_lookup
    c = Currency.lookup('EUR')
    assert_not_nil c
    assert_equal 'EUR', c.code
    assert_equal 1.6, c.rate
    assert_equal (1.6*0.5), c.rate_to_report_currency 
  end
  
  def test_rates_lookup
    old_def_code, old_def_rate, old_report_code = [$STORE_PREFS['default_currency']['code'], $STORE_PREFS['default_currency']['rate'], $STORE_PREFS['report_currency']['code']]
    $STORE_PREFS['default_currency']['code'], $STORE_PREFS['default_currency']['rate'], $STORE_PREFS['report_currency']['code'] = ['USD', nil, 'AUD']

    c = Currency.lookup('EUR')
    c.rate = nil
    # Rates may well change beyond these values - feel free to change them
    rate = c.rate
    assert rate > 1.3 && rate < 1.5, "EUR - USD rate within expected bounds (#{rate})"
    rate = c.rate_to_report_currency
    assert rate > 1.5 && rate < 1.8, "EUR - AUD rate within expected bounds (#{rate})"

    c = Currency.lookup('AUD')
    c.rate = nil
    assert_equal 1.0, c.rate_to_report_currency

    $STORE_PREFS['default_currency']['code'], $STORE_PREFS['default_currency']['rate'], $STORE_PREFS['report_currency']['code'] = [old_def_code, old_def_rate, old_report_code]
  end
  
end
