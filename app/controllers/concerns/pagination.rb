module Pagination
  extend ActiveSupport::Concern
  include Pagy::Backend

  def paginate(total_count:, page:, per_page:)
    Pagy.new(count: total_count, page: page, items: per_page)
  end
end