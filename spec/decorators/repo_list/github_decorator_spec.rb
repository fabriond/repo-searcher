require 'rails_helper'

RSpec.describe RepoList::GithubDecorator, type: :decorator do
  let(:page) { 2 }
  let(:per_page) { 3 }

  let(:decorator_instance) do
    described_class.new(
      api_response_body: api_response_body,
      page: page,
      per_page: per_page
    )
  end

  let(:api_response_body) do
    VCR.use_cassette("repo_search/github_api", record: :new_episodes) do 
      api_response = Faraday.get(
        'https://api.github.com/search/repositories', 
        {
          q: "test",
          page: page,
          per_page: per_page
        }
      )

      JSON.parse(api_response.body)
    end
  end

  context "constants" do
    it { expect(described_class::MAX_AVAILABLE_SEARCH_RESULTS).to eq(1000) }
    it { expect(described_class::DEFAULT_API_PAGE).to eq(1) }
    it { expect(described_class::DEFAULT_API_PER_PAGE).to eq(30) }
  end

  describe "#new" do
    subject { decorator_instance }

    context "when total_count >= MAX_AVAILABLE_SEARCH_RESULTS" do
      before do
        allow(api_response_body).to(
          receive(:[]).with("total_count").and_return(described_class::MAX_AVAILABLE_SEARCH_RESULTS+1)
        )

        allow(api_response_body).to receive(:[]).with("items").and_call_original
      end

      it { expect(subject.total_count).to eq(described_class::MAX_AVAILABLE_SEARCH_RESULTS) }
    end

    context "when total_count < MAX_AVAILABLE_SEARCH_RESULTS" do
      before do
        allow(api_response_body).to(
          receive(:[]).with("total_count").and_return(total_count)
        )

        allow(api_response_body).to receive(:[]).with("items").and_call_original
      end

      let(:total_count) { described_class::MAX_AVAILABLE_SEARCH_RESULTS-1 }

      it { expect(subject.total_count).to eq(total_count) }
    end

    context "when page is blank" do
      let(:page) { "" }

      it { expect(subject.page).to eq(described_class::DEFAULT_API_PAGE) }
    end

    context "when page is not blank" do
      it { expect(subject.page).to eq(page) }
    end
    
    context "when per_page is blank" do
      let(:per_page) { "" }
      
      it { expect(subject.per_page).to eq(described_class::DEFAULT_API_PER_PAGE) }
    end
    
    context "when per_page is not blank" do
      it { expect(subject.per_page).to eq(per_page) }
    end

    it { expect(subject.total_count).to be_a(Integer) }
    it { expect(subject.current_page_items.count).to be <= per_page }
    it { expect(subject.current_page_items.map(&:keys)).to all(match_array([:name, :description, :url])) }
  end

  describe "#pagination_info" do
    subject { decorator_instance.pagination_info }
    
    it { expect(subject.keys).to match_array([:page, :per_page, :total_count, :current_page_items]) }
    
    it { expect(subject[:page]).to eq(decorator_instance.page) }
    it { expect(subject[:per_page]).to eq(decorator_instance.per_page) }
    it { expect(subject[:total_count]).to eq(decorator_instance.total_count) }
    it { expect(subject[:current_page_items]).to match_array(decorator_instance.current_page_items) }
  end
end
