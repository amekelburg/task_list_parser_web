class TaskListParser::BlankTask
  
  include TaskListParser::TaskListLine
  
  attr_reader :indentation
  
  def initialize(indentation = 0)
    @indentation = indentation || 0
  end
  
  def blank?
    true
  end
  
  def to_s
  end
  
  def to_html(builder = nil, first=false)
    b = builder || Builder::XmlMarkup.new
    b.li({:class=>"tl-blank-task #{first ? 'tl-first-blank-task' : ''}"}) do |li|
      li.span({:class=>'tl-lineNumber'}, line_number)
    end
  end
  
  def to_ical
  end
  
end