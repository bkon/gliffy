require 'spec_helper'

describe Gliffy do
  it "knows the global API entry point for generic calls" do
    expect(Gliffy).to respond_to :api_root
    expect(Gliffy.api_root).to be_an_instance_of(String)
  end

  it "knows the global web entry point for generating editor-related URLs" do
    expect(Gliffy).to respond_to :web_root
    expect(Gliffy.web_root).to be_an_instance_of(String)
  end

  it "provides a default application name value" do
    expect(Gliffy).to respond_to :default_application_name
    expect(Gliffy.default_application_name).to be_an_instance_of(String)
  end

  describe "API entry point" do
    it "points to a resource at Gliffy site" do
      expect(Gliffy.api_root).to include("gliffy.com")
    end

    it "is protocol-agnostic" do
      expect(Gliffy.api_root).to_not include("http")
      expect(Gliffy.api_root).to_not include("https")
    end
  end

  describe "Web entry point" do
    it "points to a resource at Gliffy site" do
      expect(Gliffy.web_root).to include("gliffy.com")
    end

    it "is protocol-agnostic" do
      expect(Gliffy.api_root).to_not include("http")
      expect(Gliffy.api_root).to_not include("https")
    end
  end
end
