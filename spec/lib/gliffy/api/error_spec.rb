require 'spec_helper'

describe Gliffy::API::Error do
  let(:code) { 401 }
  let(:text) { "ERROR" }
  let(:error) { Gliffy::API::Error.new(code, text) }

  it "is an exception" do
    expect(error).to be_a_kind_of Exception
  end

  it "has an error code" do
    expect(error).to respond_to :code
  end

  it "has an error text" do
    expect(error).to respond_to :text
  end

  it "can be implicitly converted to string" do
    expect(error).to respond_to :to_s
  end

  describe "string representation" do
    subject(:message) { error.to_s }

    it "should contain error code" do
      expect(message).to match error.code.to_s
    end

    it "should contain error text" do
      expect(message).to match error.text
    end
  end
end
