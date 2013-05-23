helpers do
  def current_user
    return nil if session[:current_user].nil?
    user = User.find(session[:current_user])
    if user
      return user
    else
      return nil
    end
  end

  def authorized?
    redirect "/login" unless current_user
  end

  def authorize!(user)
    session[:current_user] = user.id
  end
end