module Dynamican
  module Authorization
    extend ActiveSupport::Concern

    class UnauthorizedResource < StandardError; end

    included do
      rescue_from UnauthorizedResource, with: :unauthorized
    end

    def authorize!(action, item = nil)
      raise UnauthorizedResource unless @current_user.can? action, item
    end

    def unauthorized
      render status: :unauthorized
    end
  end
end

if defined? ActiveSupport
  ActiveSupport.on_load(:action_controller) do
    include Dynamican::Authorization
  end
end
