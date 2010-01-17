class Admin::RegionalPricesController < ApplicationController
  layout "admin"
  
  before_filter :redirect_to_ssl, :check_authentication
  
  before_filter :load_product_and_currencies
  
  def new
    @regional_price = @product.regional_prices.build
  end
  
  def create
    @regional_price = @product.regional_prices.build(params[:regional_price])
    if ( @regional_price.save )
      redirect_to admin_product_url(@product)
    else
      render :action => "new"
    end
  end

  def edit
    @regional_price = RegionalPrice.find(params[:id])
  end
  
  def update
    @regional_price = RegionalPrice.find(params[:id])
    if ( @regional_price.update_attributes(params[:regional_price]) )
      redirect_to admin_product_url(@product)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @regional_price = RegionalPrice.find(params[:id])
    @regional_price.destroy
    redirect_to admin_product_url(@product)
  end
  
  private
    def load_product_and_currencies
      @product = Product.find(params[:product_id])
      @currencies = Currency.find(:all).map { |c| c.code }
    end
end
