#rubocop:disable all
module Api
  class BootstrapController < ApiController

    def index
      api_response = {
          bootstrap: {
            config: {
                elysium: {
                    pdp_url: nil
                }
            },
            user: {
                power_user: true,
                roles: ['admin'],
                name: 'Daniel Brandt',
                api_limits: {
                    sku: 50,
                    price_and_cost_change_request: 50
                }
            },
            global_nav: ''
          }
      }
      ok! api_response
    end

    def global_nav
      global_nav = MocksHelper::GLOBAL_NAV.dup
      # clear any previous and set new active nav
      global_nav[:primary].each { |item| item[:active] = item[:link] == 'utils' }
      global_nav
    end
  end
end