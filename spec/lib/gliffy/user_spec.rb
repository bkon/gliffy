# -*- coding: utf-8-unix -*-
require 'spec_helper'

describe Gliffy::User do
  let(:account_id) { 100 }
  let(:api) { double(Gliffy::API::Facade) }
  let(:account) { double(Gliffy::Account, :api => api, :id => account_id) }

  subject(:user) do
    Gliffy::User.load(
      account,
      Gliffy::API::Response.new(
        fixture('user-list')
      ).node("//g:users/g:user[1]")
    )
  end

  it "has a username" do
    expect(user).to respond_to :username
    expect(user.username).to eq "barney"
  end

  it "has an email" do
    expect(user).to respond_to :email
    expect(user.email).to eq "barney@BurnsODyne.apiuser.gliffy.com"
  end

  it "can be deleted" do
    expect(user).to respond_to :delete
  end

  context "when being deleted" do
    let(:observer) { double(Object) }

    before :each do
      api.stub(:delete_user)

      observer.stub(:update)
      user.add_observer(observer)

      user.delete
    end

    it "calls API" do
      expect(api).to have_received(:delete_user)
        .with(user.username)
    end

    it "notifies observers" do
      expect(observer).to have_received(:update)
        .with(:user_deleted, user)
    end
  end
end
