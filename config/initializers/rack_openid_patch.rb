#
#Monkey patching for adding "PAPE" support for Rack::OpenID
#

require 'openid/extensions/pape'

module Rack
  class OpenID

    private
      def begin_authentication(env, qs)
        req = Rack::Request.new(env)
        params = self.class.parse_header(qs)
        session = env["rack.session"]

        unless session
          raise RuntimeError, "Rack::OpenID requires a session"
        end

        consumer = ::OpenID::Consumer.new(session, @store)
        identifier = params['identifier'] || params['identity']
        immediate = params['immediate'] == 'true'

        begin
          oidreq = consumer.begin(identifier)
          add_simple_registration_fields(oidreq, params)

           unless params['pape'].nil?
            add_pape(oidreq,params['pape'])
          end

          add_attribute_exchange_fields(oidreq, params)
          add_oauth_fields(oidreq, params)
          url = open_id_redirect_url(req, oidreq, params["trust_root"], params["return_to"], params["method"], immediate)
          return redirect_to(url)
        rescue ::OpenID::OpenIDError, Timeout::Error => e
          env[RESPONSE] = MissingResponse.new
          return @app.call(env)
        end
      end


     def add_pape(oidreq,max_auth_age)
        papereq = ::OpenID::PAPE::Request.new
        papereq.add_policy_uri(::OpenID::PAPE::AUTH_PHISHING_RESISTANT)
        papereq.max_auth_age = max_auth_age
        oidreq.add_extension(papereq)
        oidreq.return_to_args['did_pape'] = 'y'
    end
  end
end