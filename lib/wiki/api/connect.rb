require 'net/http'
require 'json'
require 'nokogiri'

module Wiki
  module Api

    class Connect

      attr_accessor :uri, :api_path, :api_options, :http, :request, :response, :html, :parsed

      def initialize(options={})
        options.merge! @@config unless @@config.nil?
        self.uri = options[:uri] if options.include? :uri
        self.api_path = options[:api_path] if options.include? :api_path
        self.api_options = options[:api_options] if options.include? :api_options

        # defaults
        self.api_path ||= "/w/api.php"
        self.api_options ||= {action: "parse", format: "json", page: ""}

        # errors
        raise "no uri given" if self.uri.nil?
      end

      def connect
        uri = URI("#{self.uri}#{self.api_path}")
        uri.query = URI.encode_www_form self.api_options
        self.http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == "https"
          self.http.use_ssl = true 
          #self.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        self.request = Net::HTTP::Get.new(uri.request_uri)
        self.response = self.http.request(request)
      end

      def page page_name
        self.api_options[:page] = page_name
        self.connect
        response = self.response
        json = JSON.parse response.body, {symbolize_names: true}
        raise json[:error][:code] unless valid? json, response
        self.html = json[:parse][:text]
        self.parsed = Nokogiri::HTML self.html[:*]
      end

      class << self
        def config=(config = {})
          @@config = config
        end
      end

      protected
      def valid? json, response
        b = []
        # valid http response
        b << (response.is_a? Net::HTTPOK)
        # not an invalid api response handle
        b << (!json.include? :error)
        !b.include?(false)
      end

    end

  end
end