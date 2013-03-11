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
  validates_uniqueness_of :title
  validates_presence_of :title
end

binding.pry