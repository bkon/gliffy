require 'spec_helper'

describe Gliffy::Document::Presentation::SVG do
    let(:content) { "SAMPLE CONTENT" }
    let(:document) { double(Gliffy::Document) }
    let(:svg) { Gliffy::Document::Presentation::SVG.new(document) }

    it_should_behave_like "a document presentation" do
      let(:presentation) { svg }
    end

    it "has a reference to the original document" do
        expect(svg).to respond_to :document
        expect(svg.document).to be document
    end

    it "has content" do
        expect(svg).to respond_to :content
    end

    it "delegates task of fetching SVG content content to the API facade" do
        account = double(Gliffy::Account, :id => 11)
        api = double(Gliffy::API)
        document.stub(:api).and_return(api)
        document.stub(:owner).and_return(account)
        document.stub(:id).and_return(22)
        api.should_receive(
            :raw
        ).with(
            "/accounts/11/documents/22.svg",
            hash_including(
                :action => "get"
            )
        ).and_return(content)

        expect(svg.content).to eq content
    end
end
