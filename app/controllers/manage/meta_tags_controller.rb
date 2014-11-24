class Manage::MetaTagsController < Manage::BaseController

	before_filter :set_param_side

	def index
	    # @q = MetaTag.search(params[:q]) 
	    @q = MetaTag.ransack params[:q]
	    @meta_tags = @q.result.page(params[:page]).per(15)
    end

    def new
    	@meta_tag = MetaTag.new
    end

    def create
    	@meta_tag = MetaTag.new
    	@meta_tag.tag = params[:meta_tag][:tag]
    	@meta_tag.is_show = params[:meta_tag][:is_show].to_s
        @meta_tag.meta_image = params[:meta_tag][:meta_image]
    	if @meta_tag.save
    		redirect_to manage_meta_tags_path
    	else
    		render 'new'
        end
    end

    def edit
    	@meta_tag = MetaTag.find(params[:id])
    end

    def update

    	@meta_tag = MetaTag.find(params[:id])
    	@meta_tag.update_attributes(:tag=>params[:meta_tag][:tag],:meta_image=>params[:meta_tag][:meta_image],:is_show=>params[:meta_tag][:is_show].to_s)
	    if @meta_tag.save
	       redirect_to manage_meta_tags_path
	    else
	       render action: 'edit' 
	    end
    end

	private

		def set_param_side
		    params[:side] = 'manage/categories/sidebar'
		end
	  
end
