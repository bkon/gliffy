require 'spec_helper'

describe Gliffy::CLI::Task do
  let(:account) do
    double(Gliffy::Account)
  end

  let(:api) do
    api = double(Gliffy::API, :account => account)
    api.stub(:impersonate)
    api
  end

  before :each do
    Gliffy::API
      .stub(:new)
      .and_return(api)

    Gliffy::CLI::Task.any_instance.stub(:load_account).and_call_original
  end

  context "when initialized" do
    let(:options) do
      { "log-http" => false }
    end

    subject {
      Gliffy::CLI::Task.new(options)
    }

    it "loads account data" do
      Gliffy::CLI::Task.any_instance.stub(:load_credentials)
        .and_return("ID", "KEY", "SECRET")

      subject.account
      expect(subject).to have_received(:load_account).once
    end

    it "caches account data" do
      Gliffy::CLI::Task.any_instance.stub(:load_credentials)

      subject.account
      subject.account
      expect(subject).to have_received(:load_account).once
    end

    it "has a reference to the output stream" do
      expect(subject).to respond_to :stdout
      expect(subject.stdout).to be_instance_of IO
    end

    context "when user provided custom credentials" do
      let(:options) do
        {
          "account-id" => "ID",
          "consumer-key" => "KEY",
          "consumer-secret" => "SECRET"
        }
      end

      it "knows it" do
        expect(subject.has_custom_credentials?(options)).to be_true
      end

      it "uses credentials from the command line" do
        credentials = subject.load_credentials(options)

        expect(credentials).to eq ["ID", "KEY", "SECRET"]
      end
    end

    context "when user does not provide custom credentials" do
      let(:credentials_file_name) { "test.yaml" }
      let(:credentials_file_contents) do
%Q{
gliffy:
  account: 222
  oauth:
    consumer_key: "KEY2"
    consumer_secret: "SECRET2"
}
      end

      let(:options) do
        {
          "account-id" => nil,
          "consumer-key" => nil,
          "consumer-secret" => nil,
          "credentials" => credentials_file_name
        }
      end

      it "knows it" do
        expect(subject.has_custom_credentials?(options)).to be_false
      end

      it "loads credentials from the credentials file" do
        YAML.stub(:load_file).and_return(YAML.load(credentials_file_contents))

        credentials = subject.load_credentials(options)

        expect(credentials).to eq [222, "KEY2", "SECRET2"]
        expect(YAML).to have_received(:load_file).with(credentials_file_name)
      end
    end
  end

  context "during the initialization" do
    context "when log-http switch is on" do
      let(:options) do
        { "log-http" => true }
      end

      it "enables HTTP logging" do
        HttpLogger.stub(:logger=)
        subject = Gliffy::CLI::Task.new(options)
        expect(HttpLogger).to have_received :logger=
      end
    end

    context "when log-http switch is off" do
      let(:options) do
        { "log-http" => false }
      end

      it "does not enable HTTP logging" do
        HttpLogger.stub(:logger=)
        subject = Gliffy::CLI::Task.new(options)
        expect(HttpLogger).to_not have_received :logger=
      end
    end
  end
end
