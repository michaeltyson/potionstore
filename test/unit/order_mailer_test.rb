require File.dirname(__FILE__) + '/../test_helper'
require 'order_mailer'

class OrderMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  fixtures :orders, :products, :line_items
  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  
    @old_tax = $STORE_PREFS['tax']
    $STORE_PREFS['tax'] = {'AU' => {'name' => 'GST', 'rate' => 0.1}}
  end

  def teardown
    $STORE_PREFS['tax'] = @old_tax
  end

  def test_thankyou
    @actual = OrderMailer.create_thankyou(orders(:first))

    assert_equal(@actual.header['from'].to_s,$STORE_PREFS['purchase_receipt_sender_email'], '"From" correct')
    assert_equal(@actual.header['to'].to_s,orders(:first).email, '"To" correct')

    assert_match /thank you/i, @actual.body, "Be polite"

  end

  def test_tax_statement
    order = orders(:first)
    order.country = 'AU'
    
    @actual = OrderMailer.create_thankyou(order)

    assert @actual.body["#{order.tax_name}: #{order.currency.format_amount order.tax_amount}"], "Report tax"
  end


  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/order_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
