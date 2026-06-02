# frozen_string_literal: true

class MeilisearchIndexJob < ApplicationJob
  queue_as :default

  def perform(model_name, record_id, remove)
    model = model_name.constantize
    record = model.find_by(id: record_id)
    return if record.blank? && !remove

    if remove
      model.index.delete_document(record_id)
    else
      record.index!
    end
  end
end
