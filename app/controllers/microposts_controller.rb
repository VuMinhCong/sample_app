class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build micropost_params
    @micropost.image.attach(params[:micropost][:image])
    micropost_save
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t ".micropost_deleted"
    else
      flash[:danger] = t ".not_micropost_deleted"
    end
    redirect_to request.referer || root_path
  end

  private
  def micropost_params
    params.require(:micropost).permit :content, :image
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    return if @micropost

    flash[:danger] = t ".find_micropost_fail"
    redirect_to root_path
  end

  def micropost_save
    if @micropost.save
      flash[:success] = t ".save_success"
      redirect_to root_url
    else
      @pagy, @feed_items = pagy current_user.feed, items:
                                                   Settings.paginate.limit
      render "static_pages/home"
    end
  end
end
