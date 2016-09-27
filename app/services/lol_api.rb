class LolApi
  require 'open-uri'

  def get_user_data(summoner_name:)
    make_request("v1.4/summoner/by-name/#{ summoner_name }")
  end

  def get_matches(summoner_id:)
    make_request("v2.2/matchlist/by-summoner/#{ summoner_id }")
  end

  def get_match_data(match_id:)
    make_request("v2.2/match/#{match_id}")
  end


  private

  def initialize(region:)
    @region = region
    @base_url = "https://#{@region}.api.pvp.net/api/lol/#{@region}/"
  end

  def make_request(request)
    request_url  = @base_url + request + "?api_key=#{LOL_API_KEY}"
    Rails.logger.warn "Making a request to \033[32m#{request_url}\033[0m"
    JSON.parse URI.parse(request_url).read
  end

end
