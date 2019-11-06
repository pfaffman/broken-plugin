module DiscourseThinkific
  class DiscourseThinkificController < ::ApplicationController
    requires_plugin DiscourseThinkific

    before_action :ensure_logged_in

    def index
    end
  end
end
