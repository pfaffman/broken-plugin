module DiscourseThinkific
  class Engine < ::Rails::Engine
    engine_name "DiscourseThinkific".freeze
    isolate_namespace DiscourseThinkific

    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::DiscourseThinkific::Engine, at: "/discourse-thinkific"
      end
    end
  end
end
