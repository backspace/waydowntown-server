require 'rails_helper'

RSpec.describe "Result", type: :request do

  let(:member) { Member.create(name: 'me', registration_id: "1919", registration_type: "one", team: team) }
  let(:team) { Team.create(name: 'us') }

  describe "PATCH /members/:id" do
    it "stores the device id and lat/lon" do
      json = {
        data: {
          id: member.id,
          type: "member",
          attributes: {
            "registration-id": "2010",
            "registration-type": "two",
            "lat": "49.897561",
            "lon": "-97.140272"
          }
        }
      }.to_json

      patch "/members/#{member.id}", params: json, headers: { "Authorization" => "Bearer #{member.token}", "Content-Type" => "application/vnd.api+json" }
      expect(response).to have_http_status(200)

      member.reload

      expect(member.registration_id).to eq("2010")
      expect(member.registration_type).to eq("two")

      expect(member.lat).to eq(49.897561)
      expect(member.lon).to eq(-97.140272)
    end
  end
end
