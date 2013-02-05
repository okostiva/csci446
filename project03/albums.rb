#!/usr/bin/env ruby
require 'rack'
require 'sqlite3'
require 'erb'

class AlbumApp
	#Return a default value of rank so that the query still executes even if the key is not found
	@@sort_order_hash = Hash.new( "rank" )
	@@sort_order_hash[:name] = "title"
	@@sort_order_hash[:year] = "year"

	@@albums = Array.new

	def call(env)
		request = Rack::Request.new(env)
		case request.path
		when "/form" then render_form
		when "/list" then render_list(request)
		when "/styles.css" then render_stylesheet
		else render_404
		end
	end

	def populate_albums_array(order_by)
		order_column = @@sort_order_hash[order_by]

		db = SQLite3::Database.new( "albums.sqlite3.db" )
		db.execute( "select rank, title, year from albums order by " + order_column + ";" ) do |row|
			@@albums << Album.new(row[0], row[1], row[2])
		end
	end

	def render_form
		form_HTML = ERB.new(File.read("form.html.erb")).result()
		[200, {"Content-Type" => "text/html"}, [form_HTML]]
	end

	def render_list(request)
		selected_rank = request[:rank].to_i
		order_by = request[:order].to_sym
		@@albums.clear

		populate_albums_array(order_by)

		list_HTML = ERB.new(File.read("list.html.erb")).result(binding)

		[200, {"Content-Type" => "text/html"}, [list_HTML]]
	end

	def render_stylesheet
		stylesheet = ""
		File.open("styles.css", "rb") { |styles| stylesheet = styles.read}
		[200, {"Content-Type" => "text/css"}, [stylesheet]]
	end

	def render_404
		[404, {"Content-Type" => "text/plain"}, ["404 - Page Not Found!"]]
	end

end

class Album
	attr_reader :rank, :title, :year

	def initialize(rank, title, year)
		@rank = rank
		@title = title
		@year = year
	end
end

Rack::Handler::WEBrick.run AlbumApp.new, :Port => 8080


