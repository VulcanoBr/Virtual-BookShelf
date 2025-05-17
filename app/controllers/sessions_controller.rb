
class SessionsController < ApplicationController

  # GET /login
  def new
    redirect_to root_path if current_user
  end

  # POST /login
  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id

      if params[:remember_me]
        token = JsonWebToken.encode(user_id: user.id, exp: 30.days.from_now)
        cookies.signed[:auth_token] = { value: token, httponly: true, expires: 30.days.from_now }
      end

      redirect_to root_path, notice: "Bem-vindo, #{user.first_name}!"
    else
      flash.now[:alert] = "Email ou senha inválidos."
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /logout
  def destroy
    session.delete(:user_id)
    session.delete(:selected_book)
    cookies.delete(:auth_token)
    redirect_to root_path, notice: "Você saiu com sucesso."
  end
end
