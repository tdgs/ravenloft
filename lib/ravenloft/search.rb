require 'singleton'
require 'data_mapper'

module Ravenloft
  class Searcher
    include Singleton

    def initialize
      DataMapper.setup(:default, 'sqlite::memory:')
      DataMapper.finalize
      DataMapper.auto_migrate!
    end
  end

  class Importer
    BASE_URL = 'http://www.wizards.com/dndinsider/compendium/CompendiumSearch.asmx/ViewAll'

    def initialize(tab)
      url = BASE_URL + "?tab=#{tab}"
      @xml = Nokogiri::XML(open(url)) {|c| c.strict.noblanks}
      @type = @xml.xpath('//Data/Results/*').first.name
    end

    def to_a
      @array ||= @xml.xpath('//Data/Results/*').map do |node|
        node.children.inject(Hash.new) do |hash, child|
          hash.merge({child.name => child.text})
        end
      end
    end

    def save!
      # initialize db if not already initialzed
      Searcher.instance

      to_a.each do |hash|
        Resource.create(name: hash["Name"], remote_id: hash["ID"], type: @type)
      end
    end
  end

  class Resource
    include DataMapper::Resource

    property :id, Serial
    property :remote_id, Integer
    property :type, String
    property :name, String
  end
end
