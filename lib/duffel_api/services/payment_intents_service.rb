# frozen_string_literal: true

module DuffelAPI
  module Services
    class PaymentIntentsService < BaseService
      def create(options = {})
        path = "/payments/payment_intents"

        params = options.delete(:params) || {}
        options[:params] = {}
        options[:params]["data"] = params

        begin
          response = make_request(:post, path, options)

          # Response doesn't raise any errors until #body is called
          response.tap(&:raw_body)
        end

        return if response.raw_body.nil?

        Resources::PaymentIntent.new(unenvelope_body(response.parsed_body), response)
      end

      def confirm(id, options = {})
        path = substitute_url_pattern("/payments/payment_intents/:id/actions/confirm",
                                      "id" => id)

        params = options.delete(:params) || {}
        options[:params] = {}
        options[:params]["data"] = params

        begin
          response = make_request(:post, path, options)

          # Response doesn't raise any errors until #body is called
          response.tap(&:raw_body)
        end

        return if response.raw_body.nil?

        Resources::PaymentIntent.new(unenvelope_body(response.parsed_body), response)
      end

      def get(id, options = {})
        path = substitute_url_pattern("/payments/payment_intents/:id", "id" => id)

        response = make_request(:get, path, options)

        return if response.raw_body.nil?

        Resources::PaymentIntent.new(unenvelope_body(response.parsed_body), response)
      end
    end
  end
end
