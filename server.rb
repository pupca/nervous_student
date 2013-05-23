require 'sinatra'
require 'mechanize'
require 'nokogiri'
require 'net/http'
require 'mongoid'
require "awesome_print"
require "sinatra/reloader" if development?

require_relative "models/user"
require_relative "models/course"
require_relative "models/kos"
require_relative "helpers/session"
require_relative "helpers/application"

module Net
  class HTTP < Protocol
    def HTTP.new(address, port = nil, p_addr = nil, p_port = nil, p_user = nil, p_pass = nil)
      socket = Proxy(p_addr, p_port, p_user, p_pass).newobj(address, port)
      socket.ssl_version = "SSLv3"
      socket
    end
  end
end

Mongoid.load!("config/mongoid.yml")
enable :sessions
#require_relative "./init.rb"

get "/" do
  authorized?
  redirect "/settings" if current_user.setup == false
  @courses = current_user.courses.group_by{|course| course.semestr}
  erb :index
end

get "/login" do
  erb :login
end

post "/login" do
  user = User.login(params[:login], params[:password])
  if user.class == User
    authorize!(user)
    redirect "/"
  else
    redirect "/login?error=#{user}"
  end
end

get "/logout" do
  session.clear
  redirect "/login?info=logout"
end

get "/settings" do
  authorized?
  erb :settings
end

post "/settings" do
  authorized?
  current_user.update_attributes(params[:user])
  redirect "/"
end
