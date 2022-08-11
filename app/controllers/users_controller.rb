class UsersController < ApplicationController
  before_action :load_user, except: %i(index new create)
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: %i(destroy)

  def index
    @pagy, @users = pagy(
      User.all,
      page: params[:page],
      items: Settings.paginate.limit
    )
  end

  def new
    @user = User.new
  end

  def show; end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash[:success] = t "welcome"
      redirect_to @user
    else
      flash[:error] = t "signup_fail"
      render :new
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t ".update_success"
      redirect_to @user
    else
      flash[:danger] = t ".update_fail"
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t ".user_deleted"
    else
      flash[:danger] = t ".delete_fail"
    end
    redirect_to users_path
  end

  private
  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation
    )
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t ".not_found"
    redirect_to root_path
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t ".danger"
    redirect_to login_path
  end

  def correct_user
    return if current_user? @user

    flash[:error] = t ".incorrect_user"
    redirect_to root_path
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
