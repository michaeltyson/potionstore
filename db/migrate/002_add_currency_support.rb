class AddCurrencySupport < ActiveRecord::Migration
  def self.up
    create_table :regional_prices do |t|
      t.string    :currency,    :limit => 3,                                                        :null => false
      t.decimal   :amount,                      :precision => 10, :scale => 2,  :default => 0.0,    :null => false
      t.integer   :container_id
      t.string    :container_type
      t.timestamps
    end
    
    create_table :currencies do |t|
      t.string    :code,        :limit => 3,                                                        :null => false
      t.string    :unit,        :limit => 10,                                   :default => "$"
      t.integer   :precision,                                                   :default => 2
      t.string    :separator,   :limit => 2,                                    :default => "."
      t.string    :delimiter,   :limit => 2,                                    :default => ","
      t.string    :format,      :limit => 16,                                   :default => "%u%n"
      t.decimal   :rate,                        :precision => 12, :scale => 10, :default => 0.0
      t.string    :countries
      
      t.timestamps
    end
    
    change_table :orders do |t|
      t.string    :currency,    :limit => 3
      t.decimal   :currency_rate,               :precision => 12, :scale => 10, :default => 1.0 # rate for converting currency to reporting currency
    end
  end

  def self.down
    drop_table :regional_prices
    drop_table :currencies
    remove_column :orders, :currency
    remove_column :orders, :currency_rate
  end
end
