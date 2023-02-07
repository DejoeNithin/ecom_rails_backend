class EcomController < ApplicationController
  before_action :validate_auth_token
  PROD_PER_PAGE = 3
  helper_method :last_page? 

  def index
    #to execute raw sql statements
    #@skus = execute_statement("select skunits.id as id, 
     # skunits.price as price, products.product_name as name from 
      #skunits inner join products on skunits.product_id 
      #= products.id")

    #set default page number as 0 for index, else get from url
    @page = params.fetch(:page, 0).to_i
    @skus = Skunit.offset(@page * PROD_PER_PAGE).limit(PROD_PER_PAGE)
    @skusize = Skunit.all
    
    #return json
    @return = { "data" => []}
    @skus.each do |skus|
      @prod = prod(skus)
      @return["data"].push({"sku_id" => skus.id, "model_name" => skus.modelName,
         "img_url" => skus.img_url, "stock" => skus.stock, "price" => skus.price,
          "product_name" => @prod.product_name, "description" => @prod.description,
           "brand_name" => @prod.brand_name })
    end 
    @return["products_per_page"] = PROD_PER_PAGE
    #total page number
    skusize = Skunit.all.size().to_i / PROD_PER_PAGE
    if Skunit.all.size().to_i % PROD_PER_PAGE == 0
      skusize -= 1
    end 
    @return["page range"] = "0 to #{skusize}"
    render :json => @return
  end


  def page
    #json_params = JSON.parse(request.raw_post)
    #another method to parse json request
    prms = JSON.parse(request.body.read)
    skusize = Skunit.all.size().to_i / PROD_PER_PAGE
    if Skunit.all.size().to_i % PROD_PER_PAGE == 0
      skusize -= 1
    end 

    if prms["page"] < 0 || prms["page"] > skusize
      render :json => {"message" => "PAGE LIMIT EXCEEDED!!!",
       "page range" => "0 to #{skusize}",
       "products_per_page" => PROD_PER_PAGE }
    else 
      redirect_to ecom_path(page: prms["page"])
    end 
  end 

  def category_filter
    @category = Category.find_by(:name => params[:category_name])
    @sub_category = SubCategory.where(:category_id => @category.id)
    @return = { "SubCategory" => [], "Products" => []}
    
    @sub_category.each do |subc|
      @return["SubCategory"].push({"sub_category_id" => subc.id, "name" => subc.sub_category_name})
      @products = Product.where(:sub_category_id => subc.id)
      @products.each do |prod|
        @skus = Skunit.where(:product_id => prod.id)
        @skus.each do |sku|
          @return["Products"].push({"Product_id" => sku.id, "Product_name" => prod.product_name})
        end
      end
    end 

    render :json => @return
  end 


  def product_filter
    @products = Product.where('product_name LIKE ?', '%'+params[:search]+'%').all
    render :json => @products 
  end 


  def variant_filter
    @products = Product.find_by(:id => params[:product_id])
    @skunit = Skunit.where(:product_id => @products.id).all
    @skus = @skunit.pluck(:id).to_set 

    puts "products : #{@products.id}"
    puts "skunit : #{@skunit.ids}"

    params[:search].each do |search|
      @skunit.each do |skunit|
        @attr = Attribute.where('sku_id == ? AND attribute_name LIKE ? AND attribute_value LIKE ?', skunit.id, search["attribute_name"], search["attribute_value"]).all
        puts "attr : #{@attr}"
        @sku = Set[]
        @attr.each do |attr|
          @sku |= Set[attr.sku_id]
          puts "#{attr}"
        end 
        @skus &= @sku 
      end 
    end 

    @return = Skunit.where(id: @skus)
    @attr = Attribute.where(sku_id: @return)
    render :json => {:skus => @return, :attributes => @attr}
  end 


  def multi_filter
    #for category
    p_id = Set[]
    if params["category"] == ""
    else 
      c_id = Category.where('name LIKE ?', params["category"]).pluck(:id)
      s_id = SubCategory.where(:category_id => c_id).pluck(:id)
      p_id = Product.where(:sub_category_id => s_id).pluck(:id).to_set
    end 

    #for sub_category
    sp_id = Set[]
    if params["sub_category"] == ""
    else 
      s_id = SubCategory.where('sub_category_name LIKE ?', params["sub_category"]).pluck(:id)
      sp_id = Product.where(:sub_category_id => s_id).pluck(:id).to_set
    end 

    #for products
    pp_id = Set[]
    if params["product"] == ""
    else 
      pp_id = Product.where('product_name LIKE ?', '%'+params["product"]+'%').pluck(:id).to_set
    end

    #to get unique values
    result = Product.pluck(:id).to_set 
    if params["category"] != ""
      result &= p_id 
    end 
    if params["sub_category"] != ""
      result &= sp_id 
    end 
    if params["product"] != ""
      result &= pp_id 
    end 

    #result
    @products = Product.where(:id => result)

    render :json => @products 

  end 


  def price_filter
    if params["type"] == "low"
      @sku = Skunit.where('price <= ?', params["price"])
    else 
      @sku = Skunit.where('price >= ?', params["price"])
    end 
    render :json => @sku
  end

  def price_sort_by
    @skus = Skunit.all
    if params["order"] == "ascending"
      @skus = @skus.sort_by{|e| e[:price]}
    else
      @skus = @skus.sort_by{|e| -e[:price]}
    end 
    render :json => @skus 
  end 


  def show
    @skus = Skunit.find(params[:id])
    @prod = Product.find_by(:id => @skus.product_id)
    @attr = Attribute.where(:sku_id => @skus.id)
    render :json => @skus.as_json.merge(:product_info => @prod, :attributes => @attr)
  end

  private
  
  def last_page?(page)
    (page.to_i + 1) * PROD_PER_PAGE < @skusize.size().to_i
  end 

  def valid_params
    params.require(:ecom).permit(:id, :page, :name, :email, :category_name)
  end

end
