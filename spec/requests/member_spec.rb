require 'rails_helper'

RSpec.describe "Result", type: :request do

  let(:member) { Member.create(name: 'me', registration_id: "1919", registration_type: "one", team: team) }
  let(:team) { Team.create(name: 'us') }

  describe "PATCH /members/:id" do
    it "stores the device id and lat/lon" do
      beginning = Time.now

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

      expect(member.last_located).to be > beginning

      expect_attributes lat: "49.897561", lon: "-97.140272"

      expect(InviteMemberToNearbyIncarnationJob).to have_been_enqueued.with(member)
    end

    it "stores capabilities and device" do
      beginning = Time.now

      json = {
        data: {
          id: member.id,
          type: "member",
          attributes: {
            capabilities: {
              bluetooth: false,
              camera: true,
              decibels: false,
              devicemotion: false,
              location: true,
              magnetometer: true,
              ocr: true,

              exertion: true,
              height: false,
              scents: false,
              speed: true,
              stairs: false,

              fastNavigation: true,
            },
            device: {
              cordova: "a",
              model: "b",
              platform: "c",
              uuid: "d",
              version: "e",
              manufacturer: "f",
              isVirtual: "g",
              serial: "h"
            }
          }
        }
      }.to_json

      patch "/members/#{member.id}", params: json, headers: { "Authorization" => "Bearer #{member.token}", "Content-Type" => "application/vnd.api+json" }
      expect(response).to have_http_status(200)

      member.reload

      expect(member.capabilities).to eql({
        "bluetooth" => false,
        "camera" => true,
        "decibels" => false,
        "devicemotion" => false,
        "location" => true,
        "magnetometer" => true,
        "ocr" => true,

        "exertion" => true,
        "height" => false,
        "scents" => false,
        "speed" => true,
        "stairs" => false,

        "fastNavigation" => true,
      })

      expect(member.device).to eql({
        "cordova" => "a",
        "model" => "b",
        "platform" => "c",
        "uuid" => "d",
        "version" => "e",
        "manufacturer" => "f",
        "isVirtual" => "g",
        "serial" => "h"
      })
    end

    it "ignores an update with no attributes" do
      beginning = Time.now

      json = {
        data: {
          id: member.id,
          type: "member"
        }
      }.to_json

      patch "/members/#{member.id}", params: json, headers: { "Authorization" => "Bearer #{member.token}", "Content-Type" => "application/vnd.api+json" }
      expect(response).to have_http_status(200)
    end

    it "rejects invalid capabilities" do
      json = {
        data: {
          id: member.id,
          type: "member",
          attributes: {
            capabilities: {
              bluetooth: "hello",
            },
          }
        }
      }.to_json

      patch "/members/#{member.id}", params: json, headers: { "Authorization" => "Bearer #{member.token}", "Content-Type" => "application/vnd.api+json" }
      expect(response).to have_http_status(422)

      member.reload

      expect(member.capabilities).to eql({})
    end
  end

  describe "POST /members/:id/notify" do
    let(:notifier_spy) { class_spy('Notifier')}

    it "sends a notification to the member" do
      stub_const('Notifier', notifier_spy)

      post "/members/#{member.id}/notify",headers: { "Authorization" => "Bearer #{member.token}", "Content-Type" => "application/vnd.api+json" }
      expect(response).to have_http_status(201)

      expect(notifier_spy).to have_received(:notify_member).once.with(member, "A notification")
    end
  end
end
