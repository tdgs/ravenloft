require 'spec_helper'
describe Ravenloft::Manager do
  subject {Ravenloft::Manager.instance}

  before {
    subject.reset!
  }

  it "should be a singleton" do
    expect {
      Ravenloft::Manager.new
    }.to raise_error
  end

  context "with credentials" do
    before(:each) do
      pending "These tests require dnd_insider.yml" unless File.exist?("dnd_insider.yml")
    end

    it "should login" do
      subject.login!
      subject.logged_in.should be
    end

    context "with wrong credentials" do
      it "should raise error" do
        expect {
          subject.login!(username: 'lala', password: 'lala')
        }.to raise_error(Ravenloft::AuthenticationError)
      end
    end
  end
end
