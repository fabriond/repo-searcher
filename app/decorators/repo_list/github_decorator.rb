class RepoList::GithubDecorator
  # According to https://docs.github.com/v3/search/ only the first 1000 search results are available
  MAX_AVAILABLE_SEARCH_RESULTS = 1000
  DEFAULT_API_PER_PAGE = 30
  DEFAULT_API_PAGE = 1
  
  attr_reader :current_page_items, :total_count, :page, :per_page

  def initialize(api_response_body:, page:, per_page:)
    @current_page_items = decorated_items(api_response_body)
    @total_count = decorated_total_count(api_response_body)
    @page = page.blank? ? DEFAULT_API_PAGE : page
    @per_page = per_page.blank? ? DEFAULT_API_PER_PAGE : per_page
  end

  def pagination_info
    {
      total_count: total_count,
      page: page,
      per_page: per_page
    }
  end

  private

  def decorated_items(api_response_body)
    api_response_body["items"].map do |repo|
      {
        name: repo["full_name"], 
        description: repo["description"], 
        url: repo["html_url"]
      }
    end
  end

  def decorated_total_count(api_response_body)
    [api_response_body["total_count"].to_i, MAX_AVAILABLE_SEARCH_RESULTS].min
  end
end