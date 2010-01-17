require File.dirname(__FILE__) + '/../test_helper'
require 'store/notification_controller'

# Re-raise errors caught by the controller.
class Store::NotificationController; def rescue_action(e) raise e end; end

class StoreNotificationControllerTest < Test::Unit::TestCase
  fixtures :orders
  
  def setup
    @controller = Store::NotificationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @wps_params = {
      :mc_gross => '445',
      :protection_eligibility => 'Eligible',
      :address_status => 'confirmed',
      :payer_id => 'LPLWNMTBWMFAY',
      :tax => '0.00',
      :address_street => '1+Main+St',
      :payment_date => '20:12:59 Jan 13, 2009 PST',
      :payment_status => 'Completed',
      :charset => 'windows-1252',
      :address_zip => '95131',
      :first_name => 'Test',
      :mc_fee => '0.88',
      :address_country_code => 'US',
      :address_name => 'Test+User',
      :notify_version => '2.6',
      :custom => '',
      :payer_status => 'verified',
      :address_country => 'United+States',
      :address_city => 'San+Jose',
      :quantity => '1',
      :verify_sign => 'AtkOfCXbDm2hu0ZELryHFjY-Vb7PAUvS6nMXgysbElEn9v-1XcmSoGtf',
      :payer_email => 'gpmac_1231902590_per@paypal.com',
      :txn_id => '61E67681CH3238416',
      :payment_type => 'instant',
      :last_name => 'User',
      :address_state => 'CA',
      :receiver_email => $STORE_PREFS['paypal_wps_email_address'],
      :payment_fee => '0.88',
      :receiver_id => 'S8XGHLYDW9T3S',
      :txn_type => 'web_accept',
      :item_name => '',
      :mc_currency => 'USD',
      :item_number => 'BAhbB3sHaQRF8dkIaQZpBCkHAB9pBzA=', # 2 of product 1, 1 of product 2, $5 coupon
      :residence_country => 'US',
      :test_ipn => '1',
      :handling_amount => '0.00',
      :transaction_subject => '',
      :payment_gross => '19.95',
      :shipping => '0.00'
    }

    @old_def_code, @old_def_rate, @old_report_code = [$STORE_PREFS['default_currency']['code'], $STORE_PREFS['default_currency']['rate'], $STORE_PREFS['report_currency']['code']]
    $STORE_PREFS['default_currency']['code'], $STORE_PREFS['default_currency']['rate'], $STORE_PREFS['report_currency']['code'] = ['USD', nil, 'AUD']
    
  end
  
  def teardown
    $STORE_PREFS['default_currency']['code'], $STORE_PREFS['default_currency']['rate'], $STORE_PREFS['report_currency']['code'] = [@old_def_code, @old_def_rate, @old_report_code]
  end

  def test_paypal_wps_not_post
    get :paypal_wps
    assert_response 401
  end

  def test_paypal_wps_wrong_receiver
    data = @wps_params.dup
    data[:receiver_email] = 'the@wrongemail.com'
    
    post :paypal_wps, data
    assert_response 401
  end
  
  def test_paypal_wps_unauthorised_transaction
    post :paypal_wps, @wps_params.merge(:notify_validate => 'SOME RANDOM RESPONSE')
    assert_response 401
  end
  
  def test_paypal_wps_non_web_accept_type
    post :paypal_wps, @wps_params.merge(:notify_validate => 'VERIFIED', :txn_type => 'express_checkout')
    assert_response 200, 'Ignoring non web_accept type'
    assert_nil Order.find_by_transaction_number(@wps_params[:txn_id])
  end
  
  def test_paypal_wps_duplicate_transaction
    post :paypal_wps, @wps_params.merge(:notify_validate => 'VERIFIED', :txn_id => orders(:first).transaction_number)
    assert_response 200, 'Ignoring IPN duplicate'
  end
  
  def test_paypal_wps_under_paid
    post :paypal_wps, @wps_params.merge(:notify_validate => 'VERIFIED', :mc_gross => 100 )
    assert_response 200, 'Payment less than order price'
    
    order = Order.find_by_transaction_number(@wps_params[:txn_id])
    assert_not_nil order
    assert_equal 'F', order.status
  end
  
  def test_paypal_wps_pending
    post :paypal_wps, @wps_params.merge(:notify_validate => 'VERIFIED', :payment_status => 'Pending' )
    assert_response 200, 'Pending'
    
    order = Order.find_by_transaction_number(@wps_params[:txn_id])
    assert_not_nil order
    assert_equal 'P', order.status
  end
  
  def test_paypal_wps_completed
    post :paypal_wps, @wps_params.merge(:notify_validate => 'VERIFIED' )
    assert_response 201, 'Completed submission'
    
    order = Order.find_by_transaction_number(@wps_params[:txn_id])
    assert_not_nil order
    assert_equal 'C', order.status
    assert order.currency_rate > 1.0 && order.currency_rate < 1.5, "USD - AUD rate within expected bounds (#{order.currency_rate})"
  end

end
