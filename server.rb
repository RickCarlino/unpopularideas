require 'sinatra'
require 'sinatra/reloader' if development?
require 'pry' if development?
require 'mongo'
require 'mongoid'

configure do
  Mongoid.load!('mongoid.yml')
end

class Idea
  include Mongoid::Document
  field :name
  validates_uniqueness_of :name
end


#== STATIC HTTP SERVER STUFF ==

get 'favicon.ico' do
end

get '/:dir/:file' do
  #One level deep! That's all you get!
  File.open("#{params[:dir]}/#{params[:file]}").readlines
end

get '/' do
  File.open("index.html").readlines
end


#== RESTFUL API STUFF ==
#=== CRUD ===

post '/ideas' do
  #create
  request_body = JSON.parse(request.body.read.to_s)
  Idea.create(name: request_body['title'])
  binding.pry
end

get '/ideas' do
  #WARNING: THIS IS A TEMPORARY STUB!!!
  #read (all)
    content_type 'application/json'
    File.readlines('stub.json')
end

put '/ideas' do
  #update
    binding.pry
end

delete '/ideas' do
  #destroy
    binding.pry
end