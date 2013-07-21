require 'sinatra'
require 'sinatra/reloader' if development?
require 'pry' if development?
require 'pry-nav' if development?
require 'mongo'
require 'mongoid'

# Want a social network where you can talk about popular topics online? Then go sign up for reddit.
# Need a place to post your unpopular ramblings that no one wants to listen to? You're in the right place.

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

#== STATIC HTTP SERVER STUFF ==



get '/:dir/:file' do
  
  send_file File.join(params[:dir], params[:file])
end

get 'favicon.ico' do
  ''
end

get '/' do
  File.open("index.html").readlines
end

#=== REST API / Idea CRUD ===

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