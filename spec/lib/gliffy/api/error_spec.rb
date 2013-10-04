require 'spec_helper'

describe Gliffy::API::Error do
  let(:error) { Gliffy::API::Error.new }

  it "should be an exception" do
    expect(error).to be_a_kind_of Exception
  end
end
