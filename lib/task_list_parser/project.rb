class TaskListParser::Project

  include TaskListParser::TaskListLine
  
  MATCH = /(\s*)(.*):\s*$/
  #1 = spacing
  #2 = Name
  
  DAY_MATCH = /^((sun|mon|tue|wed|thu|fri|sat)[^\s]*)\s*(\d{1,2}\/\d{1,2}\/?(\d{2})?(\d{2})?)?/i
  #1 = day name
  #2 = date
  
  
  
  def self.load(line, last_date = Date.today)
    if !(line =~ MATCH)
      return nil
    else
      p = self.new
      p.last_date = last_date
      p.name = $2
      p.set_spacing($1)
      return p
    end
  end



  attr_reader :tasks, :date, :indentation, :name, :projects
  attr_accessor :last_date
  
  def initialize
    @tasks = []
    @projects = []
    @date = nil
    @indentation = 0
    @name = 'New Project'
  end
  
  
  def name=(value)
    if value =~ DAY_MATCH
      self.day= "#{$1} #{$3}"
      if date
        @name = date.strftime("%a %m/%d")
      else
        @name = value.strip
      end
    else
      @name = value.strip
    end
  end
  
  def day=(value)
    begin
      puts "Setting day via parsine '#{value}'"
      date = Date.parse(value)
      if date < last_date
        date = last_date + (7 - (last_date.wday - date.wday))
      end
      @date = date
    rescue
      @date = nil
    end
  end
  def day
    @date ? @date.strftime("%A") : ''
  end
  def is_day?
    @date ? true : false
  end
  
  def duration
    d = 0
    tasks.each do |task|
      d += task.duration
    end
    d
  end
  
  def completed
    c = 0
    tasks.each do |tast|
      c += task.completed
    end
    c
  end
  
  
  
  def set_spacing(spacing)
    if spacing =~ /#{TaskListParser::CONF[:sub_project]}*/
      @indentation = spacing.gsub(/#{TaskListParser::CONF[:sub_project]}/,'x').length
    else
      @indentation = 0
    end
  end
  
  
  
  
  
  
  def to_s
  end
  
  def to_html(builder=nil)
    b = builder || Builder::XmlMarkup.new
    
    b.div({:class=>"tl-project #{is_day? ? 'tl-date' : ''}"}) do |div|
      div.span({:class=>'tl-lineNumber'}, line_number)
      div.h3(name)
      div.ul({:class=>'tl-taskList'}) do |ul|
        tasks.each do |task|
          task.to_html(ul)
        end
      end
      projects.each do |sub_project|
        sub_project.to_html(div)
      end
    end
  end
  
  
  def to_ical
    last_end_time = nil
    ical = []
    tasks.each do |t|
      unless t.blank?
        ical += t.to_ical(last_end_time)
        last_end_time = t.end_time 
      end
    end
    ical
  end
  
  
end