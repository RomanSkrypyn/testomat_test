# frozen_string_literal: true

module CommentsHelper
  def highlight_mentions(text)
    return '' if text.blank?

    text.gsub(/@(\w+[\w.-]*)/) do |match|
      "<span class=\"text-blue-700 rounded\" >#{match}</span>"
    end.html_safe
  end
end
