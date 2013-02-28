require 'test_helper'

class ProductTest < ActiveSupport::TestCase
	test "product attributes must be defined" do
		product = Product.new
		assert product.invalid?
		assert product.errors[:title].any?
		assert product.errors[:description].any?
		assert product.errors[:price].any?
		assert product.errors[:image_url].any?
	end

	test "product price must be positive" do
		product = Product.new(title:		"My First Book",
							  description: 	"A new book",
							  image_url: 	"book.png")
		product.price = -1
		assert product.invalid?
		assert_equal ["must be greater than or equal to 0.01"], product.errors[:price]

		product.price = 0
		assert product.invalid?
		assert_equal ["must be greater than or equal to 0.01"], product.errors[:price]

		product.price = 1
		assert product.valid?
	end

	def new_product(image_url)
		Product.new(title:			"New Product Title",
					description:	"Some description",
					price:			1,
					image_url: 		image_url)
	end

	test "image url properly formatted" do
		ok_images = %w{ fred.gif fred.jpg fred.png FRED.jpg FRED.JPG http://a.b.c.d.e/x/y/z/fred.gif }
	
		bad_images = %w{ fred.doc fred.gif/extra fred.gif.extra }

		ok_images.each do |image_name|
			assert new_product(image_name).valid?, "#{image_name} should not have been invalid"
		end

		bad_images.each do |image_name|
			assert new_product(image_name).invalid?, "#{image_name} should not have been valid"
		end
	end
end
