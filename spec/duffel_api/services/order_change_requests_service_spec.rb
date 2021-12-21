# frozen_string_literal: true

require "spec_helper"

describe DuffelAPI::Services::OrderChangeRequestsService do
  let(:client) do
    DuffelAPI::Client.new(
      access_token: "secret_token",
    )
  end

  let(:response_headers) do
    {
      "content-type" => "application/json",
      "x-request-id" => "FsJz79144I4JjDwAA6TB",
    }
  end

  describe "#create" do
    subject(:post_create_response) { client.order_change_requests.create(params: params) }

    let(:params) do
      {
        order_id: "ord_0000AEdLCwAsr3d8ceyMwy",
        slices: {
          add: [
            {
              departure_date: "2021-12-18",
              cabin_class: "economy",
              destination: "JFK",
              origin: "LHR",
            },
          ],
          remove: [
            {
              slice_id: "sli_0000AEdLCwAsr3d8ceyMwz",
            },
          ],
        },
      }
    end

    let(:response_body) { load_fixture("order_change_requests/show.json") }

    let!(:stub) do
      stub_request(:post, "https://api.duffel.com/air/order_change_requests").
        with(
          body: {
            data: params,
          },
        ).
        to_return(
          body: response_body,
          headers: response_headers,
        )
    end

    it "makes the expected request to the Duffel API" do
      post_create_response
      expect(stub).to have_been_requested
    end

    it "returns the resource" do
      order_change_request = post_create_response

      expect(order_change_request).to be_a(DuffelAPI::Resources::OrderChangeRequest)

      expect(order_change_request.id).to eq("ocr_0000AEdPRxCTitEvxq8Oum")
      expect(order_change_request.live_mode).to be(false)
      expect(order_change_request.order_change_offers).to be_nil
      expect(order_change_request.slices).to eq({
        "add" => [
          {
            "cabin_class" => "economy",
            "departure_date" => "2021-12-18",
            "destination" => "JFK",
            "origin" => "LHR",
          },
        ],
        "remove" => [
          {
            "slice_id" => "sli_0000AEdLCwAsr3d8ceyMwz",
          },
        ],
      })
    end
  end

  describe "#get" do
    subject(:get_response) { client.order_change_requests.get(id) }

    let(:id) { "ocr_0000AEdPRxCTitEvxq8Oum" }

    let!(:stub) do
      stub_request(:get, "https://api.duffel.com/air/order_change_requests/ocr_0000AEdPRxCTitEvxq8Oum").
        to_return(
          body: response_body,
          headers: response_headers,
        )
    end

    let(:response_body) { load_fixture("order_change_requests/show.json") }

    it "makes the expected request to the Duffel API" do
      get_response
      expect(stub).to have_been_requested
    end

    it "returns an Order resource" do
      order_change_request = get_response

      expect(order_change_request).to be_a(DuffelAPI::Resources::OrderChangeRequest)

      expect(order_change_request.id).to eq("ocr_0000AEdPRxCTitEvxq8Oum")
      expect(order_change_request.live_mode).to be(false)
      expect(order_change_request.order_change_offers).to be_nil
      expect(order_change_request.slices).to eq({
        "add" => [
          {
            "cabin_class" => "economy",
            "departure_date" => "2021-12-18",
            "destination" => "JFK",
            "origin" => "LHR",
          },
        ],
        "remove" => [
          {
            "slice_id" => "sli_0000AEdLCwAsr3d8ceyMwz",
          },
        ],
      })
    end
  end
end