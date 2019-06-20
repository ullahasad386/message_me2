class UsersController < ApplicationController
  before_action :signed_up, only: [:new, :create]
  before_action :require_user, except: [:new, :create]
  def new
    @user = User.new

  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = "Welcome to the MessageMe app #{@user.username}"
      redirect_to chatroom_path(@user)
    else
      render 'new'
    end
  end

  def index
    @users = User.paginate(page: params[:page], per_page: 5)
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
  end

  def my_friends
    @friendships = current_user.friends
  end

  def search
    if params[:search_param].blank?
       flash.now[:danger] = "You have entered an empty search string"
     else
       @users = User.search(params[:search_param])
       @users = current_user.except_current_user(@users)
       flash.now[:danger] = "No users match this search criteria" if @users.blank?
     end
     respond_to do |format|
       format.js { render partial: 'friends/result' }
 end
end

  def add_friend
    @friend = User.find(params[:friend])
    current_user.friendships.build(friend_id: @friend.id)

    if current_user.save
      flash[:success] = "Friend was successfully added."
    else
      flash[:danger] = "There was something wrong with the friend request."
    end
    redirect_to my_friends_path
  end

  private
  def user_params
    params.require(:user).permit(:username, :password, :avatar)
  end

  def signed_up
    if logged_in?
      flash[:danger] = "You've already signed up for MessageMe"
      redirect_to chatroom_path
    end

  end

end
