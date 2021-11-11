class HomepageController < ApplicationController
  include Pagination

  def index
    repo_list = ::RepoSearch::GithubService.call(search_params)
    return if repo_list.blank?

    @repositories = repo_list.current_page_items
    @pagy_metadata = paginate(repo_list.pagination_info)
  end

  private

  def search_params
    params.permit(:repo_name, :page, :per_page).to_h.symbolize_keys
  end
end
