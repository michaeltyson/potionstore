require File.dirname(__FILE__) + '/../test_helper'

class OrderTest < Test::Unit::TestCase
  fixtures :orders, :line_items, :products, :currencies, :regional_prices, :coupons

  def setup
    @order = orders(:first)

    @old_tax = $STORE_PREFS['tax']
    $STORE_PREFS['tax'] = {'AU' => {'name' => 'GST', 'rate' => 0.1}}
    
    r = regional_prices(:euro)
    r.container = products(:first)
    r.save
  end

  def teardown
    $STORE_PREFS['tax'] = @old_tax
  end

  def test_status_description
    @dummy = Order.new
    {"P" => "Pending",
     "C" => "Complete",
     "F" => "Failed",
     "X" => "Cancelled"}.each do |abbrev, description|
      @dummy.status = abbrev
    assert_equal(@dummy.status_description , description)
    end
  end

  def test_basic_total
    test_order = Order.new
    test_order.add_form_items(products(:first).id => 1)
    
    assert_equal products(:first).price, test_order.total
    
    test_order = Order.new
    test_order.add_form_items(products(:first).id => 2)
    
    assert_equal products(:first).price * 2, test_order.total
    
    test_order = Order.new
    test_order.add_form_items(products(:first).id => 1, products(:second).id => 1)
    
    assert_equal products(:first).price + products(:second).price, test_order.total
  end
  
  def test_basic_total_with_coupon
    test_order = Order.new
    test_order.add_form_items(products(:first).id => 1)
    test_order.coupon_text = coupons(:first).coupon

    assert_not_nil test_order.coupon
    assert_equal coupons(:first).amount, test_order.coupon.amount
    assert_equal coupons(:first).amount, test_order.coupon_amount
    
    assert_equal products(:first).price - coupons(:first).amount, test_order.total
  end
  
  def test_tax_positive
    @order = Order.new
    @order.country = 'AU'
    
    assert @order.has_tax?
    assert_equal 0.1, @order.tax_rate
    assert_equal 'GST', @order.tax_name
  end

  def test_tax_negative
    @order = Order.new
    @order.country = 'US'
    
    assert !@order.has_tax?
    assert_equal 0.0, @order.tax_rate
    assert_nil @order.tax_name
  end
  
  def test_total_with_tax
    test_order = Order.new
    test_order.country = 'AU'
    test_order.add_form_items(products(:first).id => 1)
    
    assert_equal round_money(products(:first).price * 1.1), test_order.total
  end
  
  def test_total_with_tax_and_coupon
    test_order = Order.new
    test_order.country = 'AU'
    test_order.add_form_items(products(:first).id => 1)
    test_order.coupon_text = coupons(:first).coupon
    
    assert_equal round_money((products(:first).price - coupons(:first).amount) * 1.1), test_order.total
  end
  
  def test_total_with_regional_price
    test_order = Order.new
    test_order.country = 'FR'
    test_order.currency = 'EUR'
    test_order.add_form_items(products(:first).id => 1)
    
    assert_equal regional_prices(:euro).amount, test_order.total
  end
  
  def test_total_with_regional_price_auto_rate
    test_order = Order.new
    test_order.country = 'US'
    test_order.currency = 'AUD'
    test_order.add_form_items(products(:first).id => 1)
    
    assert_equal products(:first).price / currencies(:ausdollars).rate, test_order.total
  end
  
  def test_total_with_regional_price_and_tax
    test_order = Order.new
    test_order.country = 'AU'
    test_order.currency = 'EUR'
    test_order.add_form_items(products(:first).id => 1)
    
    assert_equal round_money(regional_prices(:euro).amount * 1.1), test_order.total
  end
  
  def test_coding

    test_order = Order.new
    test_order.add_form_items(products(:first).id => 2, products(:second).id => 1)
    code = test_order.tinyencode
    
    new_order = Order.new
    new_order.tinydecode code
    assert_equal (2*products(:first).price) + products(:second).price, new_order.total
    
    test_order.coupon_text = coupons(:first).coupon
    code = test_order.tinyencode
    
    assert code.length < 127

    new_order = Order.new
    new_order.tinydecode code
    assert_equal (2*products(:first).price) + products(:second).price - coupons(:first).amount, new_order.total
    
  end

end
