class House < ApplicationRecord
    validates :street, :url, presence: true
end
