# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each) do
    # Stub Comment.search to return a chainable relation of Comment.all
    # so we don't contact the Meilisearch server and Kaminari pagination still works.
    allow(Comment).to receive(:search).and_return(Comment.all)

    # Stub the MeilisearchIndexJob perform to prevent indexing during tests.
    allow(MeilisearchIndexJob).to receive(:perform_later).and_return(true)
  end
end
