require 'rails_helper'

RSpec.describe 'User' do
  let(:resource_class) { User }
  let(:all_resources)  { ActiveAdmin.application.namespaces[:admin].resources }
  let(:resource)       { all_resources[resource_class] }

  it "should be a resource" do
    expect(resource.resource_name).to eq('User')
  end

  it 'should have actions' do
    expect(resource.defined_actions).to include(:update, :index, :show, :new, :edit, :create, :destroy)
  end
end
