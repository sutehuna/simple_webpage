# frozen_string_literal: true

# Class for single memo
class SimpleFile
  attr_accessor :id, :title, :text

  def initialize(id, title, text)
    @id = id
    @title = title.encode(:xml => :text)
    @text = text.encode(:xml => :text)
  end

  def to_s
    "#{@id}, #{@title}, #{@text}"
  end
end
