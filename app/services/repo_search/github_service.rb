class RepoSearch::GithubService < ApplicationService
  require 'faraday_middleware'

  def initialize(repo_name: "", page: 1, per_page: 5)
    @repo_name = repo_name
    @page = page
    @per_page = per_page
  end

  def call
    return if repo_name.blank? || per_page.blank?
    RepoList::GithubDecorator.new(
      api_response_body: api_response.body,
      page: page,
      per_page: per_page
    )
  end

  private

  attr_reader :repo_name, :page, :per_page

  def api_response
    conn.get('/search/repositories', { q: repo_name, page: page, per_page: per_page })
  end

  def conn
    @conn ||= Faraday.new('https://api.github.com', request: { timeout: 8, open_timeout: 5 }) do |f|
      f.request :retry, retry_options
      f.response :json
    end
  end

  def retry_options
    {
      max: 2,
      interval: 0.05,
      interval_randomness: 0.5,
      backoff_factor: 2,
      exceptions: [Faraday::ConnectionFailed]
    }
  end
end