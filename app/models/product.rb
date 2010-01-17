class Product < ActiveRecord::Base
  has_many :regional_prices, :as => :container, :dependent => :destroy
  
  # Returns regional price for given currency, or creates one with a converted amount from the default currency if there's no match
  def lookup_price(currency)
    RegionalPrice.lookup(self, currency, price)
  end
  
end
