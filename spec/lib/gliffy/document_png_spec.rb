require 'spec_helper'

describe Gliffy::Document::PNG do
    let(:content) { "SAMPLE CONTENT" }
    let(:document) { double(Gliffy::Document) }
    let(:png) { Gliffy::Document::PNG.new(document) }

    it "has a reference to the original document" do
        expect(png).to respond_to :document
        expect(png.document).to be document
    end

    it "has content" do
        expect(png).to respond_to :content
    end

    it "delegates task of fetching image content to the API facade" do
        account = double(Gliffy::Account, :id => 11)
        api = double(Gliffy::API)
        document.stub(:api).and_return(api)
        document.stub(:owner).and_return(account)
        document.stub(:id).and_return(22)
        api.should_receive(
            :raw
        ).with(
            "/accounts/11/documents/22.png",
            hash_including(
                :action => "get",
                :size => "T"
            )
        ).and_return(content)

        expect(png.content(Gliffy::Document::PNG::SIZE_THUMBNAIL)).to eq content
    end

    it "has a thumbnail" do
        png.stub(:content).and_return(content)
        expect(png.thumbnail).to eq content
        expect(png).to have_received(:content).with(
            Gliffy::Document::PNG::SIZE_THUMBNAIL
        )
    end

    it "has a small image" do
        png.stub(:content).and_return(content)
        expect(png.small).to eq content
        expect(png).to have_received(:content).with(
            Gliffy::Document::PNG::SIZE_SMALL
        )
    end

    it "has a medium image" do
        png.stub(:content).and_return(content)
        expect(png.medium).to eq content
        expect(png).to have_received(:content).with(
            Gliffy::Document::PNG::SIZE_MEDIUM
        )
    end

    it "has a full image" do
        png.stub(:content).and_return(content)
        expect(png.full).to eq content
        expect(png).to have_received(:content).with(
            Gliffy::Document::PNG::SIZE_FULL
        )
    end
end