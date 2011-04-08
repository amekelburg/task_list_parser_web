class TaskListParser::Task

  include TaskListParser::TaskListLine
  
  TIME_MATCH='\d{1,2}:?\d{0,2}?[aApP]m?:'
  MATCH = /(\s*)([#{TaskListParser::CONF[:done]}#{TaskListParser::CONF[:assigned]}])?(\s*)(#{TaskListParser::CONF[:sub_task]}*#{TaskListParser::CONF[:task]}|#{TIME_MATCH})([^\[\(]*)(\(.*\))?(\[.*\])?/
  #2 = done/assigned
  #4 = time
  #5 = name
  #6 = completed/duration
  #7 = assigned project
  
  
  def self.load(line, last_time = TaskListParser::CONF[:start_time], project=nil)
    if !(line =~ MATCH)
      return nil
    else
      t = self.new
      t.last_time = last_time
      t.status=$2
      t.set_time_task_level($4)
      t.name = $5
      t.set_hours($6)
      t.set_project($7, project)
      return t
    end
  end
  
  def initialize
    @tasks = []
  end
  
  
  attr_reader :name, :time, :status, :project, :indentation, :tasks, :completed, :duration
  attr_accessor :last_time
  
  
  def status=(status_code)
    @status_code = status_code
  end
  def is_done?
    (@status_code || '').strip == TaskListParser::CONF[:done]
  end
  def is_assigned?
    (@status_code || '').strip == TaskListParser::CONF[:assigned]
  end
  
  def is_complete?
    @completed && @duration && @duration > 0 && @completed >= @duration
  end
  
  
  def set_time_task_level(time_string)
    if time_string =~ /#{TIME_MATCH}/
      @indentation = 0
      @time = Time.parse(time_string)
    else
      @time = nil
      if time_string =~ /(#{TaskListParser::CONF[:sub_task]}*)(#{TaskListParser::CONF[:task]})/
        @indentation = $1.gsub(/#{TaskListParser::CONF[:sub_task]}/,'x').length
      end
    end
  end
  
  
  
  def start_time
    time && project && project.is_day? ? Time.utc(project.date.year, project.date.month, project.date.day, time.hour, time.min, time.sec) : nil
  end

  def start_time_ical
    start_time.strftime("%Y%m%dT%H%M%S")
  end
  
  def end_time
    start_time ? start_time + 60*60*duration.to_i : nil
  end
  def end_time_ical
    end_time.strftime("%Y%m%dT%H%M%S")
  end
  
  
  def timed_uid
    "#{start_time_ical}-#{uid}"
  end
  
  def name=(name)
    @name = name ? name.strip : ''
  end
  
  def set_hours(comp_dur)
    if comp_dur =~ /(\d+)\/?(\d+)?/
      if $2
        @completed = $1.to_i
        @duration = $2.to_i
      else
        @completed = 0
        @duration = $1.to_i
      end
    else
      self.name += " #{comp_dur}"
    end
  end
  
  def set_project(proj_code,project)
    @project = project
  end
  
  
  
  
  
  
  def to_s
  end
  
  def to_html(builder = nil)
    b = builder || Builder::XmlMarkup.new
    
    b.li({:class=>"tl-task #{is_done? ? 'tl-task-done' : ''} #{is_assigned? ? 'tl-task-assigned' : ''} #{time ? 'tl-task-timed' : ''}"}) do |li|
      li.span({:class=>'tl-lineNumber'}, line_number)
      li.span({:class=>'tl-time'}, time.strftime("%l:%M%p").downcase) if time
      li.span({:class=>'tl-taskName'}, name)
      li.span({:class=>"tl-duration"}, "#{completed > 0 ? "Completed #{completed} of " : ''}#{duration}h") if duration
      if tasks.size > 0
        li.ul({:class=>'tl-subTaskList'}) do |ul|
          first_blank_task = true
          tasks.each do |sub_task|
            if sub_task.is_a?(TaskListParser::BlankTask)
              sub_task.to_html(ul, first_blank_task)
              first_blank_task = false
            else
              first_blank_task = true
              sub_task.to_html(ul)
            end
          end
        end
      end
    end
  end
  
  def to_ical(start = nil)
    ical = []
    
    if self.duration.blank? && self.time.blank?
      #It's a task
      if self.project && self.project.is_day?
        #The task has a day
      end
    else
      @time ||=  (start || TaskListParser::CONF[:start_time])
      puts "#{name} #{time}"
      #It can go on a date/time
      ical << "BEGIN:VEVENT"
      ical << "UID:#{self.timed_uid}"
      ical << "DTSTAMP;TZID=America/New_York:#{self.start_time_ical}"
      ical << "DTSTART;TZID=America/New_York:#{self.start_time_ical}"
      ical << "DTEND;TZID=America/New_York:#{self.end_time_ical}"
      ical << "SUMMARY:#{self.name}"
      ical << "CLASS:PRIVATE"
      
      ical << "END:VEVENT"
    end
    
    
    ical
  end
  
  
  
  
end