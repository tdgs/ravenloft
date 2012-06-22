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
    def initialize(xml_url)
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
