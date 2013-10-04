require 'spec_helper'

describe Gliffy::API::Response do
  let(:xml) { fixture("documents") }
  let(:response) { Gliffy::API::Response.new(xml) }

  it "allows to search node by XPath expression" do
    expect(response).to respond_to :node
    expect(
           response.node("//g:documents")
           ).to be_instance_of Gliffy::API::Response
  end

  it "allows to search for a set of nodes by XPath expression" do
    expect(response).to respond_to :nodes

    result = response.nodes("//g:document")
    expect(result).to be_instance_of Array
    expect(result.length).to eq 3
  end

  it "allows to access text node content" do
    node = response.node("//g:document[3]/g:name")
    expect(node).to respond_to :content
    expect(
           node.content
           ).to eq "World Domination Flow"
  end

  it "allows to get string node content by XPath expression" do
    expect(response).to respond_to :string
    expect(
           response.string("//g:document[2]/g:name")
           ).to eq "SNPP Domain Model"
  end

  it "allows to get integer node content by XPath expression" do
    expect(response).to respond_to :integer
    expect(
           response.integer("//g:document[1]/g:owner/@id")
           ).to eq 202
  end

  it "allows to get timestamps by XPath expression" do
    expect(response).to respond_to :timestamp
    expect(
           response.timestamp("//g:document[1]/g:create-date")
           ).to eq Time.at(1215538283000 / 1000).to_datetime
  end

  it "allows to check for a node existence by XPath" do
    expect(response).to respond_to :exists
    expect(response.exists("//g:document[1]/@is-public")).to be_false
    expect(response.exists("//g:document[2]/@is-public")).to be_true
  end
end
