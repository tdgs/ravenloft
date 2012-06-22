require 'singleton'
require 'data_mapper'

module Ravenloft
  class Searcher
    include Singleton

    TABS = %w(
      Background Theme Class Companion Monster Deity Disease EpicDestiny
      Feat Glossary Item ParagonPath Poison Power Race Ritual Terrain Traps
    )

    def initialize
      DataMapper.setup(:default, 'sqlite::memory:')
      DataMapper.finalize
      DataMapper.auto_upgrade!

      TABS.each do |tab|
        Importer.new(tab).save!
      end
    end

    def query(q, type = nil)
      results = Resource.all(:name.like => "%#{q}%")
      results = results.all(type: type) if type
      results
    end

  end

  # NOTE: should be called only after Searcher has been initialized
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

    def card_html
      Ravenloft.login!.get(type, remote_id)
    end
  end
end
