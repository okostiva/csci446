#!/usr/bin/env ruby

require 'rack'
require 'sqlite3'

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
				albumInfo = albumLine.chomp.split(', ')
				tempAlbum = Album.new(counter, albumInfo[0], albumInfo[1])
				albums << tempAlbum
				counter = counter + 1
			end
		end

		case request[:order].to_s
		when "rank"
		then albums.sort! { |album1, album2| album1.rank.to_i <=> album2.rank.to_i }
		when "name"
		then albums.sort! { |album1, album2| album1.title.to_s <=> album2.title.to_s }
		when "year"
		then albums.sort! { |album1, album2| album1.year.to_i <=> album2.year.to_i }
		end

		File.open("list.html", "rb") do |list|
			while (listLine = list.gets)
				if listLine.index('<!-- Table Item Placeholder -->')
					albums.each do |tempAlbum|
						if tempAlbum.rank.to_i == request[:rank].to_i
							listHTML << "<tr class='selected'>\n"
						else
							listHTML << "<tr>\n"
						end
						listHTML << "\t<td>" + tempAlbum.rank.to_s + "</td>\n"
						listHTML << "\t<td>" + tempAlbum.title.to_s + "</td>\n"
						listHTML << "\t<td>" + tempAlbum.year.to_s + "</td>\n"
						listHTML << "</tr>\n"
					end
				elsif listLine.index('<!-- Sort Order Placeholder -->')
					listHTML << "<p>Sorted by " + request[:order].capitalize.to_s + "</p>\n"
				else
					listHTML << listLine.to_s
				end
			end
		end

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


