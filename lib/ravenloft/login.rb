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



		def initialize
			@cookies = []
		end


		def viewstate(html)
			html.at_css("input[name=__VIEWSTATE]")[:value]
		end

		def event_validation(html)
			html.at_css("input[name=__EVENTVALIDATION]")[:value]
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
			@cookies << c.find {|i| i =~ /iPlanet/}.split(';').first
		end

		def get(type, id)
			url = URL + "#{type}.aspx?id=#{id}"
			Nokogiri::HTML(open(url, "Cookie" => @cookies.join('; ')).read)
		end
	end
end
