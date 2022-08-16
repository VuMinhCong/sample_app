class PasswordResetsController < ApplicationController
  before_action :ghet_user, :valid_user, :check_expiration, only:
                                                            %i(edit update)

  def new; end

  def edit; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t(".send_email")
      redirect_to root_path
    else
      flash.now[:danger] = t(".email_not_found")
      render :new
    end
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add :password, t(".empty")
      render :edit
    elsif @user.update(user_params)
      log_in @user
      flash[:success] = t(".reset_pass")
      redirect_to @user
    else
      render :edit
    end
  end

  private
  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def ghet_user
    @user = User.find_by email: params[:email]
    return if @user

    flash[:danger] = t(".not_found")
    redirect_to signup_path
  end

  def valid_user
    return if @user.activated? && @user.authenticated?(:reset, params[:id])

    flash[:danger] = t ".alert_user"
    redirect_to root_path
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t(".exprired")
    redirect_to new_password_reset_url
  end
end
