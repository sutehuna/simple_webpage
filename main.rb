# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require_relative 'simple_io'
require_relative 'simple_file'

enable :method_override

before do
  update_max_id
end

helpers do
  def update_max_id
    @max_id = SimpleIO.read_all.map { |f| f.id.to_i }.max || 0
  end
end

get '/' do
  @titles = SimpleIO.read_all.map { |f| "<a class=\"titlebox\" href=\"/memos/#{f.id}\">#{f.title}</a>" }.join("<br>\n")
  erb :index
end

get '/new' do
  erb :new
end

get '/memos/:number' do |n|
  @file = SimpleIO.read(n)
  @number = n
  erb :show
end

get '/memos/:number/edit' do |n|
  @file = SimpleIO.read(n)
  @number = n
  erb :edit
end

post '/memos' do
  @max_id += 1
  SimpleIO.write(SimpleFile.new(@max_id, params[:title], params[:text]))
  redirect to('/')
end

patch '/memos/:number' do |n|
  SimpleIO.write(SimpleFile.new(n, params[:title], params[:text]))
  redirect to('/')
end

delete '/memos/:number' do |n|
  SimpleIO.delete(n)
  redirect to('/')
end
