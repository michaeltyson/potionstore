ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up ''
  # -- just remember to delete public/index.html.
  map.root :controller => 'store/order'
  map.connect 'store', :controller => "store/order"

  # The following is necessary for installations in a sub-directory (it won't hurt for webroot installations, though)
  map.connect 'order/:action', :controller => 'store/order'
  map.connect 'notification/:action', :controller => 'store/notification'
  map.connect 'lost_license/:action', :controller => 'store/lost_license'
  map.connect 'products/:action', :controller => 'store/products'

  # Map the order controller as a resource so that it can take JSON orders from Cocoa frontend
  # NOTE: This must come after the admin mapping
  map.resource :order, :path_prefix => 'store', :controller => 'store/order'

  # admin stuff
  map.resources :products, :name_prefix => 'admin_', :path_prefix => 'admin', :controller => 'admin/products' do |products|
    products.resources :regional_prices, :controller => 'admin/regional_prices'
  end
  map.resources :orders,   :name_prefix => 'admin_', :path_prefix => 'admin', :controller => 'admin/orders'
  map.connect 'admin/currencies/countries_for_currency', :controller => 'admin/currencies', :action => 'countries_for_currency'
  map.resources :currencies, :name_prefix => 'admin_', :path_prefix => 'admin', :controller => 'admin/currencies'
  map.connect 'admin/charts/:action', :controller => 'admin/charts'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  #   map.connect ':controller/service.wsdl', :action => 'wsdl'

  map.connect 'bugreport/crash', :controller => 'email', :action => 'crash_report'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
