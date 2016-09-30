class SmiteRequestsController < ApplicationController

  def index
    @query = Query.new({region: 'euw'})
  end

  def query_results
    @first_player = query_params.first_player.summoner_name
    @second_player = query_params.second_player.summoner_name


    if @first_player.present? && @second_player.present?
      first_player_match_ids = match_ids @first_player
      second_player_match_ids = match_ids @second_player

      @matches_played_ids = first_player_match_ids & second_player_match_ids
    end

    if @matches_played_ids.present?
      @matches_played = @matches_played_ids.map do |match_id|
        match_data(match_id)
      end
    end

  rescue OpenURI::HTTPError => error
    Rails.logger.error "\e[#{31}m#{error.message}\e[0m"
    @error = error.message
  ensure
    render :index
  end

  private

  def api
    @api ||= SmiteApi.new
  end

  def query_params
    @query ||= Query.new params.require(:query).permit(first_player: [:summoner_name], second_player: [:summoner_name])
  end

  def match_ids(player)
    api.get_matches(player: player).map {|a| a['Match']}
  end

  def match_data(match_id)
    data = api.get_match_data(match_id: match_id)

    { match_creation: data.first['Entry_Datetime'] }.tap do |outcome|
      outcome[:winners] = data.select {|entry| entry['Win_Status'] == 'Winner'}.map do |winner_data|
        winner_data['playerName'].split(']').last
      end
    end

  end
end
