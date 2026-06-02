# frozen_string_literal: true

module Comments
  module Meilisearchable
    extend ActiveSupport::Concern

    included do
      include Meilisearch::Rails

      scope :meilisearch_import, -> { includes(:user) }

      meilisearch enqueue: :meilisearch_index_job, raise_on_failure: Rails.env.development? do
        searchable_attributes %i[body]
        sortable_attributes %i[updated_at]
      end
    end

    class_methods do
      def meilisearch_index_job(record, remove)
        ::MeilisearchIndexJob.perform_later(record.class.to_s, record.id, remove)
      end
    end
  end
end
