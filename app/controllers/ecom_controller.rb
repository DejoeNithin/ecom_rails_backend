class EcomController < ApplicationController
  before_action :validate_auth_token
  PROD_PER_PAGE = 3
  helper_method :last_page? 

  def index
    #@skus = Skunit.all
    #@skus = execute_statement("select skunits.id as id, 
     # skunits.price as price, products.product_name as name from 
      #skunits inner join products on skunits.product_id 
      #= products.id")
    #@skus = Skunit.all 
    #@prod = Product.all

    @page = params.fetch(:page, 0).to_i
    @skus = Skunit.offset(@page * PROD_PER_PAGE).limit(PROD_PER_PAGE)
    @skusize = Skunit.all
    
    @return = { "data" => []}
    @skus.each do |skus|
      @prod = prod(skus)
      @return["data"].push({"sku_id" => skus.id, "model_name" => skus.modelName,
         "img_url" => skus.img_url, "stock" => skus.stock, "price" => skus.price,
          "product_name" => @prod.product_name, "description" => @prod.description,
           "brand_name" => @prod.brand_name })
    end 
    @return["products_per_page"] = PROD_PER_PAGE
    skusize = Skunit.all.size().to_i / PROD_PER_PAGE
    if Skunit.all.size().to_i % PROD_PER_PAGE == 0
      skusize -= 1
    end 
    @return["page range"] = "0 to #{skusize}"
    render :json => @return
  end

  def page
    #json_params = JSON.parse(request.raw_post)
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
    
    #render :json => {"hi" => prms["name"] }
    #redirect_to ecom_path(page: :page)
  end 

  def category_filter
    @category = Category.find_by(:name => params[:category_name])
    @sub_category = SubCategory.where(:category_id => @category.id)
    @return = { "SubCategory" => [], "Products" => []}
    puts "sc : #{@sub_category}"
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
    #puts "#{params}"
    #@return = params
    #render :json => @return
    @products = Product.find_by(:id => params[:product_id])
    @skunit = Skunit.where(:product_id => @products.id).all
    @skus = Set[]
    puts "products : #{@products.id}"
    puts "skunit : #{@skunit.ids}"
    params[:search].each do |search|
      @skunit.each do |skunit|
        @attr = Attribute.where('sku_id == ? AND attribute_name LIKE ? AND attribute_value LIKE ?', skunit.id, search["attribute_name"], search["attribute_value"]).all
        puts "attr : #{@attr}"
        @attr.each do |attr|
          @skus |= Set[attr.sku_id]
          puts "#{attr}"
        end 
      end 
    end 
    @return = Skunit.where(id: @skus)
    @attr = Attribute.where(sku_id: @return)
    render :json => {:skus => @return, :attributes => @attr}
  end 


  def multi_filter
    p_id = Set[]
    if params["category"] == ""
    else 
      c_id = Category.where('name LIKE ?', params["category"]).pluck(:id)
      s_id = SubCategory.where(:category_id => c_id).pluck(:id)
      p_id = Product.where(:sub_category_id => s_id).pluck(:id).to_set
    end 

    puts "1 p_id : #{p_id}"

    sp_id = Set[]
    if params["sub_category"] == ""
    else 
      s_id = SubCategory.where('sub_category_name LIKE ?', params["sub_category"]).pluck(:id)
      sp_id = Product.where(:sub_category_id => s_id).pluck(:id).to_set
    end 

    pp_id = Set[]
    if params["product"] == ""
    else 
      pp_id = Product.where('product_name LIKE ?', '%'+params["product"]+'%').pluck(:id).to_set
    end

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

    @products = Product.where(:id => result)

    render :json => @products 

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
