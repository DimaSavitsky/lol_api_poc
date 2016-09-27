class Query

  attr_accessor :struct
  delegate :region, :first_player, :second_player, to: :struct

  private

  def initialize(hash)
    @struct = JSON.parse(hash.to_json, object_class: OpenStruct)
  end

end
