class RegionalPrice < ActiveRecord::Base

  belongs_to :container, :polymorphic => true
  validates_presence_of :amount, :currency
  validates_numericality_of :amount
  
  def self.default_with_amount(amount)
    p = self.new
    p.amount = amount
    p.currency = Currency.default
    return p
  end
  
  # Returns regional price for given currency, or creates one with a converted amount from the default currency if there's no match
  def self.lookup(container, currency, default_price)
    return self.default_with_amount(default_price) if currency == :default
    
    begin
      regional_price = container.regional_prices.find_by_currency(currency.class == Currency ? currency.code : currency)
      return regional_price if regional_price
    rescue
    end
  
    currency = Currency.lookup(currency) if currency.class != Currency
    raise ArgumentError.new("No such currency") if !currency
    
    regional_price = RegionalPrice.new
    regional_price.currency = currency
    regional_price.amount = default_price / currency.rate
    return regional_price
  end
  
  def formatted_amount
    begin
      currency.format_amount amount
    rescue
      amount
    end
  end
  
  def currency 
    Currency.lookup(super) || Currency.default
  end
  
  def currency=(code)
    super(code.class == Currency ? code.code : code)
  end
  
end
