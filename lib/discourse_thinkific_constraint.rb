class DiscourseThinkificConstraint
  def matches?(request)
    SiteSetting.discourse_thinkific_enabled
  end
end
