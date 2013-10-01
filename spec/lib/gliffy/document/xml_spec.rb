require 'spec_helper'

describe Gliffy::Document::XML do
    let(:content) { "SAMPLE CONTENT" }
    let(:document) { double(Gliffy::Document) }
    let(:xml) { Gliffy::Document::XML.new(document) }

    it "has a reference to the original document" do
        expect(xml).to respond_to :document
        expect(xml.document).to be document
    end

    it "has content" do
        expect(xml).to respond_to :content
    end

    it "delegates task of fetching XML content content to the API facade" do
        account = double(Gliffy::Account, :id => 11)
        api = double(Gliffy::API)
        document.stub(:api).and_return(api)
        document.stub(:owner).and_return(account)
        document.stub(:id).and_return(22)
        api.should_receive(
            :raw
        ).with(
            "/accounts/11/documents/22.xml",
            hash_including(
                :action => "get"
            )
        ).and_return(content)

        expect(xml.content).to eq content
    end
end
