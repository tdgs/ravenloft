require 'spec_helper'

describe Ravenloft::Power do
  let(:mock_manager) do
    mock(:manager).as_null_object
  end

  before (:each) do
    Ravenloft.stub(:read_credentials).
      and_return({"username" => "none@nowhere.com", "password" => "secret"})

    Ravenloft::Manager.stub(:instance).and_return(mock_manager)
  end

  context "on Magic Missile" do
    before(:each) do
      mock_manager.stub(:get).with('power', 463) do
        File.read('spec/fixtures/magic_missile.html')
      end
    end

    magic_missile = Psych.load_file('spec/fixtures/magic_missile.yml')

    subject do
      Ravenloft::Power.new(463).tap(&:get!).tap(&:parse!)
    end

    magic_missile.each do |key, value|
      its(key) { should == value }
    end
  end

  context "on Levy of Judgment" do
    before(:each) do
      mock_manager.stub(:get).with('power', 12605) do
        File.read('spec/fixtures/levy_of_judgment.html')
      end
    end

    levy_of_judgment = Psych.load_file('spec/fixtures/levy_of_judgment.yml')

    subject do
      Ravenloft::Power.new(12605).tap(&:get!).tap(&:parse!)
    end

    levy_of_judgment.each do |key, value|
      its(key) { should == value }
    end
  end
end
