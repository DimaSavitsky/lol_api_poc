class RequestsController < ApplicationController

  def index
    @query = Query.new({region: 'euw'})
  end

  def query_results
    @first_player = find_or_initialize_player(summoner_name: query_params.first_player.summoner_name)
    @second_player = find_or_initialize_player(summoner_name: query_params.second_player.summoner_name)

    if @first_player && @second_player
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
    @api ||= LolApi.new(region: query_params.region)
  end

  def query_params
    @query ||= Query.new params.require(:query).permit(:region, first_player: [:summoner_name], second_player: [:summoner_name])
  end

  def find_or_initialize_player(summoner_name:)
    scope = User.where(region: query_params.region).where(summoner_name: summoner_name)
    scope.first || scope.create(summoner_id: api.get_user_data(summoner_name: summoner_name).values.first['id'] )
  rescue
    nil
  end

  def match_ids(player)
    api.get_matches(summoner_id: player.summoner_id)['matches'].map {|match| match['matchId'] }
  end

  def match_data(match_id)
    data = api.get_match_data(match_id: match_id)['MatchDetail']
    { match_creation: DateTime.strptime(data['matchCreation'],'%s'), mode: data['matchMode'] }.tap do |outcome|
      winner_team = outcome['teams'].find {|team| team['winner'] }
      winner_team_id = winner_team['teamId']

      winner_participant_ids = data['participants'].map do |participant|
        participant['participantId'] if participant['teamId'] == winner_team_id
      end
      winner_participant_ids.compact!

      outcome[:winners] = data['participantIdentities'].map do |identity|
        if identity['participantId'].in? winner_participant_ids
          identity['player']['summonerId']
        end
      end.compact

    end
  end

end
