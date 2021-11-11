require 'rails_helper'

RSpec.describe RepoSearch::GithubService, type: :service do
  let(:service_instance) { described_class.new(repo_name: repo_name, page: page, per_page: per_page) }
  let(:repo_name) { 'test' }
  let(:page) { 2 }
  let(:per_page) { 3 }

  describe '#call' do
    subject do
      VCR.use_cassette('repo_search/github_api', record: :new_episodes) { service_instance.call }
    end

    context 'when repo_name is blank' do
      let(:repo_name) { '' }

      it { expect(subject).to be_nil }
    end

    context 'when per_page is blank' do
      let(:per_page) { '' }

      it { expect(subject).to be_nil }
    end

    context 'when both repo_name and per_page are present' do
      context 'when page is blank' do
        let(:page) { '' }

        it { expect(subject.page).to eq(1) }
      end

      it 'makes http request with faraday to the github api' do
        expect_any_instance_of(Faraday::Connection).to(
          receive(:get).with('/search/repositories', { q: repo_name, page: page, per_page: per_page })
        ).and_call_original

        subject
      end

      it 'makes request and decorates response' do
        mocked_response_body = 'response_body'

        allow_any_instance_of(Faraday::Response).to receive(:body).and_return(mocked_response_body)

        expect_any_instance_of(Faraday::Connection).to(
          receive(:get).with('/search/repositories', { q: repo_name, page: page, per_page: per_page })
        ).and_call_original

        expect(RepoList::GithubDecorator).to(
          receive(:new).with(api_response_body: mocked_response_body, page: page, per_page: per_page)
        )

        subject
      end

      it { expect(subject.class).to eq(RepoList::GithubDecorator) }
    end
  end
end
