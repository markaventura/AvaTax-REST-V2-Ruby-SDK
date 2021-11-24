require 'faraday'
require 'json'
require "erb"
require "addressable/uri"


module AvaTax
  module Request

    def get(path, options={})
      request(:get, path, nil, options)
    end

    def post(path, model, options={})
      request(:post, path, model, options)
    end

    def put(path, model, options={})
      request(:put, path, model, options)
    end

    def delete(path, options={})
      request(:delete, path, nil, options)
    end

    def request(method, path, model, options={})
      response = connection.send(method) do |request|
        # timeout in seconds
        request.options['timeout'] = 1200
        case method
        when :get, :delete
          request.url("#{Addressable::URI.encode(path)}?#{URI.encode_www_form(options)}")
        when :post, :put
          request.url("#{Addressable::URI.encode(path)}?#{URI.encode_www_form(options)}")
          request.headers['Content-Type'] = 'application/json'
          request.body = model.to_json unless model.empty?
        end
      end

      if faraday_response
        response
      else
        response.body
      end
    end

    private

    def encode_path(path)
      path.split('/').map { |part| ERB::Util.url_encode(part) }.join('/')
    end
  end
end