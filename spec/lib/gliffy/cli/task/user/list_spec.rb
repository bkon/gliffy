require 'spec_helper'

describe Gliffy::CLI::Task::User::List do
  let(:user1) do
    double(Gliffy::User,
           :username => "username1",
           :email => "email1@test.com")
  end

  let(:user2) do
    double(Gliffy::User,
           :username => "username2",
           :email => "email2@test.com")
  end

  let(:account) do
    double(Gliffy::Account)
  end

  let(:stdout) do
    stdout = double(STDOUT)
    stdout.stub(:puts)
    stdout
  end

  subject do
    Gliffy::CLI::Task::User::List
      .any_instance
      .stub(:account)
      .and_return(account)

    Gliffy::CLI::Task::User::List
      .new({ "account-id" => "ID",
             "consumer-key" => "KEY",
             "consumer-secret" => "SECRET",
             "user" => "USERNAME" },
           {},
           {})
  end

  before :each do
    account.stub(:users).and_return([user1, user2])
    subject.stub(:stdout).and_return(stdout)
  end

  it "loads a list of users" do
    subject.run

    expect(account).to have_received :users
  end

  it "displays users" do
    subject.run

    expect(stdout).to have_received(:puts)
      .with(match(user1.username))

    expect(stdout).to have_received(:puts)
      .with(match(user1.email))

    expect(stdout).to have_received(:puts)
      .with(match(user2.username))

    expect(stdout).to have_received(:puts)
      .with(match(user2.email))
  end
end
