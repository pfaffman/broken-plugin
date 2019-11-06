# frozen_string_literal: true

# name: DiscourseThinkific
# about: Log in to Thinkific on login
# version: 0.1
# authors: pfaffman
# url: https://github.com/pfaffman

require 'securerandom' unless defined?(SecureRandom)
register_asset 'stylesheets/common/discourse-thinkific.scss'
register_asset 'stylesheets/desktop/discourse-thinkific.scss'
register_asset 'stylesheets/mobile/discourse-thinkific.scss'

enabled_site_setting :thinkific_enabled

# TODO: don't enable unless url and api key

PLUGIN_NAME ||= 'DiscourseThinkific'

load File.expand_path('lib/discourse-thinkific/engine.rb', __dir__)

after_initialize do
  # https://github.com/discourse/discourse/blob/master/lib/plugin/instance.rb
  class ::SessionController
    # def create
    #   puts "\n\n\nSession happening!\n\n\n\n"
    #   super
    # end
    def login(user)
      puts "\n\n\n\LOGIN happening!\n\n\n\n"
      session.delete(ACTIVATE_USER_KEY)
      log_on_user(user)

      if payload = cookies.delete(:sso_payload)
        sso_provider(payload)
      else
        if true # plugin is enabled and has api key and url
          sign_into_thinkific(user)
        else
          render_serialized(user, UserSerializer)
        end
      end
    end

    def sign_into_thinkific(user)
      puts "\n\n\nreally Signing IN!!!\n\n\n"
      puts "\n\n\nID #{user.id} IN!!!\n\n\n"
      puts "\n\n\nNAME#{user.name} IN!!!\n\n\n"
      # from https://support.thinkific.com/hc/en-us/articles/360030718713-SSO-Automatically-Sign-in-From-Your-Own-Website?source=search
      iat = Time.now.to_i
      jti = "#{iat}/#{SecureRandom.hex(18)}"
      if user.name
        first_name = user.name.split(' ').first
        last_name = user.name.split(' ').last
        puts "Got names! #{first_name} --- #{last_name}"
      else
        first_name = 'missing first name'
        last_name = 'missing last name'
      end
      payload = JWT.encode({
                             :iat   => iat,
                             :jti   => jti,
                             :first_name  => first_name,
                             :last_name => last_name,
                             :email => user.email,
                           }, SiteSetting.thinkific_api_key)
      puts "Signing in payload!!! #{payload}"

      redirect_to thinkific_sso_url(payload)
    end

    def thinkific_sso_url(payload)
      current_url="https://#{GlobalSetting.hostname}/"
      url = "https://#{SiteSetting.thinkific_site_url}api/sso/v2/sso/jwt?jwt=#{payload}"
#      url += "&return_to=#{URI.escape(params["return_to"])}" if SiteSetting.thinkific_return_url.present?
      url += "&return_to=#{URI.escape(current_url)}" if true
      url += "&error_url=#{URI.escape(params["error_url"])}" if SiteSetting.thinkific_error_url.present?

      puts "HERE IS URL: #{url}"

      url
    end



  end

  module ::ThinkificSSO
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace ThinkificSSO
    end
  end

  # class ::UserAuthToken
  #   # from discourse/app/models/user_auth_token.rb
  #   def self.generate!(user_id: , user_agent: nil, client_ip: nil, path: nil, staff: nil, impersonate: false)
  #     puts "\n\n\n\nUserAuthToken JP\n\n\n\n\n"
  #     token = SecureRandom.hex(16)
  #     hashed_token = hash_token(token)
  #     user_auth_token = UserAuthToken.create!(
  #       user_id: user_id,
  #       user_agent: user_agent,
  #       client_ip: client_ip,
  #       auth_token: hashed_token,
  #       prev_auth_token: hashed_token,
  #       rotated_at: Time.zone.now
  #     )
  #     user_auth_token.unhashed_auth_token = token

  #     log(action: 'generate',
  #         user_auth_token_id: user_auth_token.id,
  #         user_id: user_id,
  #         user_agent: user_agent,
  #         client_ip: client_ip,
  #         path: path,
  #         auth_token: hashed_token)

  #     if staff && !impersonate
  #       Jobs.enqueue(:suspicious_login,
  #                    user_id: user_id,
  #                    client_ip: client_ip,
  #                    user_agent: user_agent)
  #     end

  #     user = User.find(user_id)
  #     puts "\n\n\nFound user: #{user.username}\n\n\n"
  #     self.sign_into_thinkific(user)
  #     user_auth_token
  #   end

  #   private

  # end

  DiscourseEvent.on(:after_auth) do |auth|
    puts "\n\n\n\nIt's after auth time!!!\n\n\n\n"
  end

end
