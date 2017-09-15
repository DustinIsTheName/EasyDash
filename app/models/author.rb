class Author < ActiveRecord::Base
	belongs_to :shop

	validates :name, uniqueness: true
end