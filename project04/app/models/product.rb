class Product < ActiveRecord::Base
  has_many :line_items

  before_destroy :ensure_not_referenced_by_any_line_item

  attr_accessible :description, :image_url, :price, :title

  validates :title, :description, :image_url, presence: true
  validates :price, numericality: {greater_than_or_equal_to: 0.01}
  validates :title, uniqueness: true
  validates :image_url, allow_blank: true, format: {
	with: %r{\.(gif|jpg|png)\Z}i,
	message: 'must be a URL for a GIF, JPG or PNG image file.'
  }
  validates :title, allow_blank: true, length: {
	minimum: 10,
	message: 'must be at least 10 characters'
  }

  private
    #ensure that there are no line items referencing this product
    def ensure_not_referenced_by_any_line_item
      if line_items.empty?
        return true
      else
        errors.add(:base, 'Line Items present')
        return false
      end
    end
end
