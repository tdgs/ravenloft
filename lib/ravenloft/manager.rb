require 'singleton'

module Ravenloft
  SEARCH_URL = URL + "CompendiumSearch.asmx"
  LOGIN_URL = URL + "login.aspx?page=monster&id=339"

  class NotLoggedInError < StandardError
  end

  class AuthenticationError < StandardError
  end

  extend self 

  def login!
    Manager.instance.tap {|m|
      m.login!
    }
  end

  def read_credentials
    h = YAML.load(File.open('dnd_insider.yml'))
    h["dnd_insider"]
  end


  class Manager
    include Singleton

    attr_reader :logged_in

    def initialize
      @cookies = []
      @logged_in = false
      @credentials = nil
    end

    def credentials
      @credentials ||= Ravenloft.read_credentials
    end

    def username
      credentials["username"]
    end

    def password
      credentials["password"]
    end

    # @return [Ravenloft::Manager]
    def login!(opts = {})
      if @logged_in
        return self unless opts[:force]
      end

      u = opts[:username] || username
      p = opts[:password] || password


      @logged_in = false  

      # get event validation and viewstate
      html = Nokogiri::HTML(open(LOGIN_URL).read)

      params = {
        "email" => u,
        "password" =>  p,
        "InsiderSignin" => "Sign In",
        "__EVENTVALIDATION" => event_validation(html),
        "__VIEWSTATE" => viewstate(html)
      }

      url = URI.parse(LOGIN_URL)
      resp, data = Net::HTTP.post_form(url, params)


      c = resp.get_fields('set-cookie')

      raise AuthenticationError unless c

      planet_cookie = c.find {|i| i =~ /iPlanet/}.split(';').first
      if planet_cookie
        @cookies << planet_cookie
        @logged_in = true
      end

      self
    end

    def get_url(url)
      raise NotLoggedInError.new unless @logged_in

      open(url, "Cookie" => @cookies.join('; '))
    end

    # @return [StringIO] the D&D Insider Response
    def get_response(type, id)

      url = URL + "#{type}.aspx?id=#{id}"
      get_url(url)
    end


    # @return [String] with the details of the requested resource
    def get(type, id)
      resp = get_response(type, id)
      Nokogiri::HTML(resp.read).at_css("#detail").inner_html.strip
    end

    def reset!
      self.send(:initialize)
    end

    private 

    def viewstate(html)
      html.at_css("input[name=__VIEWSTATE]")[:value]
    end

    def event_validation(html)
      html.at_css("input[name=__EVENTVALIDATION]")[:value]
    end
  end
end
