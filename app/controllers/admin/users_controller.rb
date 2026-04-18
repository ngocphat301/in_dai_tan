class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: %i[edit update destroy toggle_role]

  def index
    @users = User.all
    if (p = admin_like_pattern)
      @users = @users.where("email ILIKE ?", p)
    end
    @users = apply_admin_order(@users, allowed: %w[email updated_at role], default: "updated_at")
    pag = admin_paginate(@users)
    @users = pag[:records]
    @admin_page = pag[:page]
    @admin_total_pages = pag[:total_pages]
    @admin_total_count = pag[:total_count]
  end

  def new
    @user = User.new(role: :member)
  end

  def create
    admin = User.create(role: :admin, email: "admin1@gmail.com", password: "password", password_confirmatio: "password")
    @user = User.new(user_params_create)
    if @user.save
      redirect_to admin_users_path, notice: "Đã tạo người dùng."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attrs = user_params_update
    if attrs[:password].blank?
      attrs = attrs.except(:password, :password_confirmation)
    end
    if @user.update(attrs)
      redirect_to admin_users_path, notice: "Đã cập nhật người dùng."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle_role
    if @user == current_user
      redirect_back fallback_location: admin_users_path, alert: "Không đổi vai trò của chính bạn tại đây."
      return
    end

    new_role = @user.admin? ? :member : :admin
    if @user.update(role: new_role)
      redirect_back fallback_location: admin_users_path, notice: "Đã đổi vai trò."
    else
      redirect_back fallback_location: admin_users_path, alert: @user.errors.full_messages.to_sentence.presence || "Không cập nhật được."
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: "Bạn không thể xóa chính mình."
      return
    end

    if @user.destroy
      redirect_to admin_users_path, notice: "Đã xóa người dùng."
    else
      redirect_to admin_users_path, alert: @user.errors.full_messages.to_sentence.presence || "Không xóa được."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params_create
    params.require(:user).permit(:email, :role, :password, :password_confirmation)
  end

  def user_params_update
    params.require(:user).permit(:email, :role, :password, :password_confirmation)
  end
end
