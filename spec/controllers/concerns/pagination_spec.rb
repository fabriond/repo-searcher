require 'rails_helper'

RSpec.describe Pagination, type: :concern do  

  before(:all) do
    class PaginationTestController < ApplicationController
      include Pagination
    end
  end

  after(:all) do
    Object.send :remove_const, :PaginationTestController 
  end

  let(:controller_instance) { PaginationTestController.new }

  describe "#paginate" do
    subject do
      controller_instance.paginate(
        total_count: total_count, 
        page: page, 
        per_page: per_page
      )
    end

    let(:total_count) { 6 }
    let(:page) { 2 }
    let(:per_page) { 3 }

    it "creates pagination metadata using Pagy.new" do
      mocked_pagy_instance = "pagy_instance"
      pagy_options = { count: total_count, page: page, items: per_page }
      expect(Pagy).to receive(:new).with(pagy_options).once.and_return(mocked_pagy_instance)

      expect(subject).to eq(mocked_pagy_instance)
    end
  end
end
