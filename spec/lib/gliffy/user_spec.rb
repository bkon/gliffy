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
end
