# class Manage::SelfiesController < Manage::BaseController

#     before_filter :set_param_side

# 	def new
# 		@selfie = Selfie.new
# 		@brands = Brand.all
# 	end

# 	def create
# 		@selfie = Selfie.new
# 		@selfie.user_id = 1
# 		@selfie.title = params[:selfie][:title]
# 		@selfie.desc = params[:selfie][:desc]
# 		@selfie.price = params[:selfie][:price].to_i
# 		@selfie.tag_list.add(params[:selfie][:tags])
# 		@selfie.brand_id = params[:brand].to_i
# 		@selfie.cover_image= params[:selfie][:cover_image]
# 		if @selfie.save
# 			if @selfie.photos.size == 0
# 		      @selfie.dapei_info_flag = 1
# 		    end
# 			redirect_to manage_selfies_path
# 		else
# 			render 'new'
# 		end
# 	end

# 	   #批量上传
# 	def create_image 
# 	    @html = HtmlPage.new(image: params[:file])
# 	    @html.save!
# 	    str = ""
# 	    str = str + @html.image.to_s
# 	    return render js: str
# 	end

# 	private

# 		def set_param_side
# 		    params[:side] = 'manage/matters/sidebar'
# 		end
# end