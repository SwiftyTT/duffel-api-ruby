# frozen_string_literal: true

require "spec_helper"

describe DuffelAPI::Response do
  subject(:response) { described_class.new(raw_response) }

  let(:raw_response) { faraday_connection.get("/testing") }

  let(:stubbed_faraday_adapter) do
    Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get("/testing") do |_env|
        [200, response_headers, response_body]
      end
    end
  end

  let(:faraday_connection) do
    Faraday.new do |builder|
      builder.adapter :test, stubbed_faraday_adapter
    end
  end

  let(:response_body) do
    load_fixture("offer_requests/create_with_offers.json")
  end

  let(:response_headers) do
    {
      "content-type" => "application/json",
      "x-request-id" => "FsJz79144I4JjDwAA6TB",
    }
  end

  describe "#body" do
    subject(:body) { response.body }

    it "returns the body parsed into a hash" do
      expect(body["data"]["id"]).to eq("orq_0000AEatBgHzrn02B7WwEa")
    end

    context "when the response is empty" do
      let(:response_body) { "" }

      it "returns nil" do
        expect(body).to be_nil
      end
    end
  end

  describe "#request_id" do
    it "returns the request ID from the response headers" do
      expect(response.request_id).to eq("FsJz79144I4JjDwAA6TB")
    end
  end

  describe "#meta" do
    context "with meta data returned in the response" do
      let(:response_body) do
        load_fixture("aircraft/list.json")
      end

      it "returns it, as a hash" do
        expect(response.meta).to eq({
          "after" => "g3QAAAACZAACaWRtAAAAGmFyY18wMDAwOVZNRjhBZ3BWNXNkTzB4WEIwZAAEbmFt" \
                     "ZW0AAAAPQWlyYnVzIEEzNDAtNTAw",
          "before" => nil,
          "limit" => 50,
        })
      end
    end

    context "without meta data returned in the response" do
      it "returns an empty hash" do
        expect(response.meta).to eq({})
      end
    end
  end
end
