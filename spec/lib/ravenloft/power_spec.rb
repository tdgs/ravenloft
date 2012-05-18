require 'spec_helper'

describe Ravenloft::Power do
	before (:each) do
		Ravenloft::Manager.instance.stub(:get).with('power', 463) do
			File.read('spec/fixtures/magic_missile.html')
		end
	end

  magic_missile = {
		name: "Magic Missile",
		klass: "Wizard", 
    attack_utility: "Attack",
		level: 1,
		flavor: "A glowing blue bolt of magical energy hurtles from your finger and unerringly strikes your target.",
		frequency: 'At-Will', 
    type: 'Standard Action',
		keywords: %w(Arcane Evocation Force Implement),
    range: "Ranged",
    range_modifier: "20",
		target: 'One creature',
    attack: nil,
    miss: nil, 
    sustain: nil,
		effects: ["2 + Intelligence modifier force damage.",
							"Level 11: 3 + Intelligence modifier force damage.",
							"Level 21: 5 + Intelligence modifier force damage."],

		special: "If the implement used with this power has an enhancement bonus, " + 
							"add that bonus to the damage. In addition, you can use this power " + 
							"as a ranged basic attack.",
    published_in: "Published in Player's Handbook, page(s) 159, Heroes of the Fallen Lands, page(s) 203, Neverwinter Campaign Setting, page(s) 74, Class Compendium."
	}
			
		
  subject do
		pow = Ravenloft::Power.new(463)
    pow.get!
    pow.parse!
    pow
  end

  magic_missile.each do |key, value|
    its(key) { should == value }
	end
end
