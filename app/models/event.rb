class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :info, type: Hash

  belongs_to :user

  def is_blocked(device_id)
  	$redis.hexists(device_id, self.name)
  end

  def increment_counter(device_id)
  	$redis.hincrby(device_id, self.name, 1)
  end

  def get_attributes
  	self.info
  end

end
