#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require_relative 'simple_io'
require_relative 'simple_file'

enable :method_override

helpers do
  def max_id
    SimpleIO.max_id
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  @files = SimpleIO.read_all
  erb :index
end

get '/new' do
  erb :new
end

get '/memos/:number' do |n|
  if SimpleIO.exist?(n)
    @file = SimpleIO.read(n)
    erb :show
  else
    erb :not_found
  end
end

get '/memos/:number/edit' do |n|
  if SimpleIO.exist?(n)
    @file = SimpleIO.read(n)
    erb :edit
  else
    erb :not_found
  end
end

post '/memos' do
  SimpleIO.write(SimpleFile.new(max_id + 1, params[:title], params[:text]))
  redirect to('/')
end

patch '/memos/:number' do |n|
  if SimpleIO.exist?(n)
    SimpleIO.update(SimpleFile.new(n, params[:title], params[:text]))
    redirect to('/')
  else
    erb :not_found
  end
end

delete '/memos/:number' do |n|
  SimpleIO.delete(n)
  redirect to('/')
end

not_found do
  erb :not_found
end
