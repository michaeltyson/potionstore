require File.dirname(__FILE__) + '/../test_helper'
require 'store/order_controller'

# Re-raise errors caught by the controller.
class Store::OrderController; def rescue_action(e) raise e end; end

class StoreOrderControllerTest < Test::Unit::TestCase
  fixtures :orders
  
  def setup
    @controller = Store::OrderController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @order      = orders(:first)
  end

  def test_get_index
    get :index
    assert_response :success
  end

  def test_wps_receipt_analytics
    last_analytics_code = $STORE_PREFS['google_analytics_account'];
    $STORE_PREFS['google_analytics_account'] = 'UA-123456-7'
    
    ENV['RAILS_ENV'] = 'production'
    post :wps_thankyou, nil, {:order_details => {'txn_id' => @order.transaction_number}}
    assert_response :success
    assert_select "#utmtrans"
    ENV['RAILS_ENV'] = 'test'
    
    $STORE_PREFS['google_analytics_account'] = last_analytics_code;
  end

end
