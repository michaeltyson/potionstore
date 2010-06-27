require 'xavier_media_currency_conversion'

class Currency < ActiveRecord::Base

  validates_length_of :code, :is => 3
  validates_length_of :countries, :minimum => 2
  
  include ActionView::Helpers::NumberHelper
  
  def self.default
    c = self.new
    
    c.code      = $STORE_PREFS['default_currency']['code'] || 'USD'
    c.rate      = 1.0
    c.precision = $STORE_PREFS['default_currency']['precision'] || 2
    c.unit      = $STORE_PREFS['default_currency']['unit']
    c.separator = $STORE_PREFS['default_currency']['separator'] || '.'
    c.delimiter = $STORE_PREFS['default_currency']['delimiter'] || ','
    c.format    = $STORE_PREFS['default_currency']['format'] || '%u%n'
    
    return c
  end
  
  def self.report_currency
    c = self.new
    
    c.code      = $STORE_PREFS['report_currency']['code'] || 'USD'
    c.rate      = 1.0
    c.precision = $STORE_PREFS['report_currency']['precision'] || 2
    c.unit      = $STORE_PREFS['report_currency']['unit']
    c.separator = $STORE_PREFS['report_currency']['separator'] || '.'
    c.delimiter = $STORE_PREFS['report_currency']['delimiter'] || ','
    c.format    = $STORE_PREFS['report_currency']['format'] || '%u%n'
    
    return c
  end
  
  
  def self.default_countries_for_currency(three_letter_currency_code)
    return [] if !three_letter_currency_code || three_letter_currency_code.empty?
    countries = []
    require 'csv'
    # Note: currencies.csv adapted from http://www.jhall.demon.co.uk/currency/by_country.html
    CSV.open("#{RAILS_ROOT}/config/currencies.csv", "r") { |r| countries << r[1] if r[3] =~ /.*#{three_letter_currency_code}.*/ }
    return countries;
  end

  def self.lookup(code)
    return self.default if code == ($STORE_PREFS['default_currency']['code'] || 'USD')
    return find_by_code(code)
  end
  
  def self.find_with_country(country_code)
    self.find(:first, :conditions => ["countries LIKE ?", "%#{country_code}%"]) rescue nil
  end
  
  def countries
    return (super && super.split(',')) || []
  end
  
  def countries=(val)
    super(val.class == Array ? val.join(',') : val)
  end
  
  def rate_set?
    return self[:rate] != nil && self[:rate] != 0.0
  end
  
  def rate
    
    if code.empty? || code == $STORE_PREFS['default_currency']['code']
       return 1.0
    end

    return super if super && super != 0.0

    begin
      amount = XavierMedia::exchange_rate(code, ($STORE_PREFS['default_currency']['code'] || 'USD'))
    rescue Exception => e
      logger.warn("Couldn't get currency conversion rate for #{code} to #{($STORE_PREFS['default_currency']['code'] || 'USD')}: #{e.inspect}")
      return 1.010101
    end
    
    return amount
  end
  
  def rate_to_report_currency
    if code == ($STORE_PREFS['default_currency']['code'] || 'USD')
      return $STORE_PREFS['default_currency']['rate'].to_f if $STORE_PREFS['default_currency']['rate']
      begin  
        return XavierMedia::exchange_rate(($STORE_PREFS['default_currency']['code'] || 'USD'), $STORE_PREFS['report_currency']['code'])
      rescue Exception => e
        logger.warn("Couldn't get currency conversion rate for #{($STORE_PREFS['default_currency']['code'] || 'USD')} to #{$STORE_PREFS['report_currency']['code']}: #{e.inspect}")
        return 1.010101
      end
    end
    return rate * Currency.default.rate_to_report_currency
  end
  
  def rate=(val)
    super(val == nil ? 0.0 : val)
  end
  
  def format_amount(amount, args = {})
    number_to_currency amount, {:precision => precision, :unit => unit, :separator => separator, :delimiter => delimiter, :format => format}.merge(args)
  end
  
end
