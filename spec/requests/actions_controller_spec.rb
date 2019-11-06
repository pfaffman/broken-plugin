require 'rails_helper'

describe DiscourseThinkific::ActionsController do
  before do
    Jobs.run_immediately!
  end

  it 'can list' do
    sign_in(Fabricate(:user))
    get "/discourse-thinkific/list.json"
    expect(response.status).to eq(200)
  end
end
