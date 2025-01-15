# frozen_string_literal: true

require "faraday"
require "uri"

module DuffelAPI
  # An internal class used within the library that is able to make requests to
  # the Duffel API and handle errors
  class APIService
    # Sets up an API service based on a base URL, access token and set of default
    # headers
    #
    # @param base_url [String] A test or live mode access token
    # @param access_token [String] The URL of the Duffel API
    # @param default_headers [Hash] The headers to include by default in HTTP requests
    # @param request_logger [Object]
    # @return [APIService]
    def initialize(base_url, access_token, default_headers:, request_logger: nil)
      @base_url = base_url
      root_url, @path_prefix = unpack_url(base_url)

      @connection = Faraday.new(root_url) do |conn|
        conn.request :rate_limiter
        conn.response :raise_and_log_duffel_errors, logger: request_logger

        conn.adapter(:net_http)
      end

      @headers = default_headers.merge("Authorization" => "Bearer #{access_token}", "Duffel-Version" => "v2")
    end

    # Makes a request to the API, including any defauot headers
    #
    # @param method [Symbol] the HTTP method to make the request with
    # @param path [String] the path to make the request to
    # @param options [Hash] options to be passed with `Request#new`
    # @return [Request]
    def make_request(method, path, options = {})
      raise ArgumentError, "options must be a hash" unless options.is_a?(Hash)

      options[:headers] ||= {}
      options[:headers] = @headers.merge(options[:headers])
      Request.new(@connection, method, @path_prefix + path, **options).call
    end

    private

    def unpack_url(url)
      path = URI.parse(url).path
      [URI.join(url).to_s, path == "/" ? "" : path]
    end
  end
end
