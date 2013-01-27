#!/usr/bin/env ruby

require 'rack'

class AlbumApp
	def call(env)
		request = Rack::Request.new(env)
		case request.path
		when "/form" then render_form
		when "/list" then render_list(request)
		when "/styles.css" then render_stylesheet
		else render_404
		end
	end

	def render_form
		formHTML = ""

		File.open("form.html", "rb") do |form|
			while (formLine = form.gets)
				if formLine.index('<!-- Option Placehoder -->')
					(1..100).each do |rankNum|
						formHTML << "<option value='" + rankNum.to_s + "'>" + rankNum.to_s + "</option>\n"
					end
				else
					formHTML << formLine.to_s
				end
			end
		end

		[200, {"Content-Type" => "text/html"}, [formHTML]]
	end

	def render_list(request)
		listHTML = ""
		albums = Array.new
		counter = 1

		File.open("top_100_albums.txt") do |allAlbums|
			while (albumLine = allAlbums.gets)
				albumInfo = albumLine.split(', ')
				tempAlbum = Album.new(counter, albumInfo[0], albumInfo[1])
				##tempAlbum.initialize(counter, albumInfo[0], albumInfo[1])
				albums << tempAlbum
				counter = counter + 1
			end
		end

		File.open("list.html", "rb") do |list|
			while (listLine = list.gets)
				listHTML << listLine.to_s
			end
		end

##		listHTML << albums[0].rank.to_s

		[200, {"Content-Type" => "text/html"}, [listHTML]]
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


