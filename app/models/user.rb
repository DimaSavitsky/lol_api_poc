class User < ApplicationRecord

  validates :summoner_id, presence: true

  def inspect
    {  summoner_id: summoner_id, summoner_name: summoner_name, region: region }
  end

end
