class SmiteApi
  attr_reader :requests

  def get_matches(player:)
    make_request 'getmatchhistory', player
  end

  def get_match_data(match_id:)
    make_request 'getmatchdetails', match_id
  end

  private

  def initialize()
    @base_url = 'http://api.smitegame.com/smiteapi.svc/'

    @dev_id = SMITE_DEV_ID
    @auth_key = SMITE_AUTH_KEY

    @requests = 0

    create_session
  end


  def make_request(action, *params)
    stamp = timestamp

    action_sign = sign(action, stamp) + ( action == 'createsession' ? '' : "/#{@session_id}" )

    request_url  = @base_url + "#{action}Json/#{@dev_id}/#{action_sign}/#{stamp}"

    if params.present?
      request_url += '/' + params.join('/')
    end

    Rails.logger.warn "#{timestamp} - Making a request to \033[32m#{request_url}\033[0m"
    @requests += 1

    response = JSON.parse URI.parse(request_url).read
    Rails.logger.info response.inspect
    response
  end

  def create_session
    @session_id = nil

    until @session_id
      response = make_request "createsession"

      if response['session_id'].present?
        @session_id = response['session_id']
        @session_created = Time.now
      end
    end
  end

  def sign(method, stamp)
    Digest::MD5.new.hexdigest [@dev_id, method, @auth_key, stamp].join
  end

  def timestamp
    (Time.now).utc.strftime("%Y%m%d%H%M%S")
  end

end