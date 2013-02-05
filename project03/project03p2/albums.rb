#!/usr/bin/env ruby
require 'sinatra'
require 'data_mapper'
require_relative 'album'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/albums.sqlite3.db")

set :port, 8080

get "/form" do
	erb :"form.html", :layout => :"layout.html"
end

post "/list" do
	#Return a default value of rank so that the query still executes even if the key is not found
	@sort_order_hash = Hash.new( :rank )
	@sort_order_hash[:name] = :title
	@sort_order_hash[:year] = :year
	@albums = Album.all(:order => [@sort_order_hash[params[ :order ].to_sym]])
	erb :"list.html", :layout => :"layout.html"
end
