
class SimpleFile
  attr_accessor :id, :title, :text
  
  def initialize(id, title, text)
    @id = id
    @title = title
    @text = text
  end

  def to_s
    "#{@id}, #{@title}, #{@text}"
  end
end