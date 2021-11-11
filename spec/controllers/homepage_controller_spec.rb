require 'rails_helper'

RSpec.describe HomepageController, type: :controller do
  describe 'GET index' do
    let(:params) { {} }

    subject { get(:index, params: params) }

    context 'when there are no params' do
      it 'returns status ok and renders index html' do
        subject

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:index)
        expect(response.content_type).to eq('text/html')
      end
    end

    context 'when there is a repo_name in params' do
      before { params[:repo_name] = 'test' }

      it 'returns status ok, renders index html, calls github repo search service and paginates results' do
        expect(RepoSearch::GithubService).to receive(:call).with(params).once.and_return(
          VCR.use_cassette('repo_search/github_api', record: :new_episodes) do
            RepoSearch::GithubService.call(params)
          end
        )
        expect_any_instance_of(described_class).to receive(:paginate).once.and_call_original

        subject

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:index)
        expect(response.content_type).to eq('text/html')

        expect(assigns(:pagy_metadata)).to be_a(Pagy)
        expect(assigns(:repositories)).to be_a(Array)
        expect(assigns(:repositories).first.keys).to match_array(%i[name description url])
      end
    end
  end
end
