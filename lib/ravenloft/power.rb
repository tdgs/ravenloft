require 'ostruct'

module Ravenloft

  class Power < OpenStruct

    attr_accessor :uid, :doc

    def initialize(uid)
      super(Hash.new)
      @uid = uid
    end

    def self.manager
      Ravenloft::Manager.instance.login!
    end

    def get!
      @doc = self.class.get(@uid)
    end

    def self.get(uid)
      response = manager.get('power', uid)

      # Replace all &nbsp; because Nokogiri replaces them with \u00a0 which
      # String#strip does not count as a space.
      response.gsub!(/&nbsp;/, ' ')

      Nokogiri::HTML::DocumentFragment.parse(response)
    end

    def parse!
      doc.children.each do |e|
        detect_line!(e)
      end
    end

    def detect_line!(elem)
      case
      when elem.name == 'h1'
        extract_title!(elem)
      when elem.attr('class') == 'publishedIn'
        extract_published_in!(elem)
      when elem.name == 'p' && elem.attr('class') == 'flavor' && \
        elem.children.size == 1 &&  elem.children.first.name == 'i'

        extract_flavor_text!(elem)
      when elem.at_css('b') && elem.at_css('b').text =~ /^target$/i
        extract_target!(elem)
      when elem.at_css('b') && elem.at_css('b').text =~ /^special$/i
        extract_special!(elem)
      when elem.at_css('b') && elem.at_css('b').text =~ /^effect$/i
        extract_effect!(elem)
      when elem.at_css('b') && elem.at_css('b').text =~ /^attack$/i
        extract_attack!(elem)
      when elem.at_css('b') && elem.at_css('b').text =~ /^hit$/i
        extract_hit!(elem)
      when elem.at_css('b') && elem.at_css('b').text =~ /^miss$/i
        extract_miss!(elem)
      when elem.at_css('b') && elem.at_css('b').text =~ /^prerequisite$/i
        extract_prerequisite!(elem)
      when elem.at_css('b') && elem.at_css('b').text =~ /^(at-will|encounter|daily)$/i
        extract_power_stats!(elem)
      end
    end

    def extract_prerequisite!(elem)
      elem.children.find{|c| c.name == 'b'}.remove
      self.prerequisite = elem.text.strip.sub(/^: ?/, '')
    end

    def extract_attack!(elem)
      elem.children.find{|c| c.name == 'b'}.remove
      self.attack = elem.text.strip.sub(/^: ?/, '')
    end

    def extract_hit!(elem)
      elem.children.find{|c| c.name == 'b'}.remove
      self.hit = elem.text.strip.sub(/^: ?/, '')
    end

    def extract_miss!(elem)
      elem.children.find{|c| c.name == 'b'}.remove
      self.miss = elem.text.strip.sub(/^: ?/, '')
    end

    def extract_power_stats!(elem)
      children = elem.children
      img = children.find{|c| c.name == 'img'}
      img.remove if img

      self.frequency = children.shift.text

      self.keywords = []
      while (child = children.shift) && (child.name != 'br') do
        self.keywords << child.text if child.name == 'b'
      end

      self.type = children.shift.text

      children.shift if children[0].text.strip.empty?

      self.range = children.shift.text
      if mod = children.shift
        case self.range
        when "Ranged", "Area"
          self.range_modifier = mod.text.strip
        end
      end
    end

    def extract_effect!(elem)
      elem.children.find{|c| c.name == 'b'}.remove
      elem.children.select{|c| c.name == 'br'}.each(&:remove)
      self.effects = elem.children.map{|e| e.text.strip.sub(/^: ?/, '')}
    end

    def extract_special!(elem)
      elem.children.find{|c| c.name == 'b'}.remove
      self.special = elem.text.strip.sub(/^: ?/, '')
    end

    def extract_target!(elem)
      elem.children.find{|c| c.name == 'b'}.remove
      self.target = elem.text.strip.sub(/^: ?/, '')
    end

    def extract_title!(elem)
      children = elem.children
      while child = children.shift do
        next if child.text.strip.empty?
        case
        when child.name == "span"
          words = child.text.strip.split
          self.level = words.pop.to_i
          self.attack_utility = words.pop
          self.klass = words.join(' ')
        else
          self.name = child.text.strip
        end
      end
    end

    def extract_published_in!(elem)
      self.published_in = elem.text.strip
    end

    def extract_flavor_text!(elem)
      self.flavor = elem.text.strip
    end
  end
end

