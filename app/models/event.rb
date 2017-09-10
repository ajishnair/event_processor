class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :info, type: Hash

  belongs_to :user

  def is_blocked(device_id)
    #if redis is down don't block events
    begin
  	  return $redis.hexists(device_id, self.name)
    rescue Redis::BaseConnectionError => ex
      logger.error("Redis timeout error : " + ex.message)
      return false
    end
  end

  def increment_counter(device_id)
    begin
  	  $redis.hincrby(device_id, self.name, 1)
    rescue Redis::BaseConnectionError => ex
      logger.error("Redis timeout error : " + ex.message)
    end
  end

  def get_attributes
  	self.info
  end

end
