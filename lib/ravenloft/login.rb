module Ravenloft
  SEARCH_URL = URL + "CompendiumSearch.asmx"
  LOGIN_URL = URL + "login.aspx?page=monster&id=339"

  extend self 
  def login!(username, password)
    Manager.new.tap {|m|
      m.login!(username, password)
    }
  end
  class Manager

    attr_reader :logged_in

    def initialize
      @cookies = []
      @logged_in = false
    end


    def login!(username, password)

      # get event validation and viewstate
      html = Nokogiri::HTML(open(LOGIN_URL).read)

      params = {
        "email" => username,
        "password" =>  password,
        "InsiderSignin" => "Sign In",
        "__EVENTVALIDATION" => event_validation(html),
        "__VIEWSTATE" => viewstate(html)
      }

      url = URI.parse(LOGIN_URL)
      resp, data = Net::HTTP.post_form(url, params)

      c = resp.get_fields('set-cookie')
      planet_cookie = c.find {|i| i =~ /iPlanet/}.split(';').first
      if planet_cookie
        @cookies << planet_cookie
        @logged_in = true
      end

      @cookies
    end


    # @return [StringIO] the D&D Insider Response
    def get_response(type, id)
      url = URL + "#{type}.aspx?id=#{id}"
      open(url, "Cookie" => @cookies.join('; '))
    end


    # @return [String] with the details of the requested resource
    def get(type, id)
      resp = get_response(type, id)
      Nokogiri::HTML(resp.read).at_css("#detail").inner_html.strip
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
