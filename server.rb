require 'sinatra'
require 'sinatra/reloader' if development?
require 'pry' if development?
require 'pry-nav' if development?
require 'mongo'
require 'mongoid'

#DISCLAIMER--------------------

#==============================
# This backend is minimally
# viable to the fullest extent
# of the law. The focus of this
# app was learning CRUD in 
# backbone, rather than how to 
# build a pragmatic RESTful API.
# Please Keep that in mind.
#==============================

configure do
  Mongoid.load!('mongoid.yml')
end

class Idea
  include Mongoid::Document
  field :title
  validates_length_of :title, :minimum => 2, maximum: 50
  validates_uniqueness_of :title
  validates_presence_of :title
end

get '/:dir/:file' do
  
  send_file File.join(params[:dir], params[:file])
end

get 'favicon.ico' do
  ''
end

get '/' do
  File.open("index.html").readlines
end

post '/ideas' do
  #create
  content_type 'application/json'
  request_body = JSON.parse(request.body.read.to_s)
  new_idea = Idea.create(title: request_body['title'])

  if new_idea.errors.any?
    status 400
  else
    return new_idea.to_json
  end

end

get '/ideas' do
  #read (all)
    content_type 'application/json'
    Idea.all.limit(15).reverse.to_json
end

put '/ideas/:id' do
  content_type 'application/json'
  request_body = JSON.parse(request.body.read.to_s)
  idea = Idea.find(@params[:id])
  idea.update_attributes(title: request_body['title'])
  if idea.errors.any?
    return 400
  else
    return idea.to_json
  end
  #update
end

delete '/ideas/:id' do
  #destroy
    Idea.find(params[:id]).destroy
end