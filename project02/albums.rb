#!/usr/bin/env ruby

require 'rack'

class AlbumApp
	def call(env)
		request = Rack::Request.new(env)
		case request.path
		when "/form" then render_form(request)
		when "/list" then render_list(request)
		when "/styles.css" then render_stylesheet(request)
		else render_404
		end
	end

	def render_form(request)
		response = Rack::Response.new
		
		finalHTML = ""

		File.open("form.html", "rb") do |form|
			while (line = form.gets)
				if line.index('<!-- Option Placehoder -->')
					(1..100).each do |rankNum|
						finalHTML << "<option value='" + rankNum.to_s + "'>" + rankNum.to_s + "</option>\n"
					end
				else
					finalHTML << line.to_s
				end
			end
		end

		response.write(finalHTML)
		response.finish
	end

	def render_list(request)
		response = Rack::Response.new(request.path)
		response.finish
	end

	def render_stylesheet(request)
		response = Rack::Response.new
		File.open("styles.css", "rb") { |styles| response.write(styles.read) }
		response.finish
	end

	def render_404
		[404, {"Content-Type" => "text/plain"}, ["404 - Page Not Found!"]]
	end

end

Rack::Handler::WEBrick.run AlbumApp.new, :Port => 8080


