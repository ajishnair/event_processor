class User
  include Mongoid::Document
  field :name, type: String
  field :device_id, type: String

  has_many :events
end
