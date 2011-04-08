class TaskListParser::List
  
  
  def self.load(list_text)
    last_date = Date.today
    
    list = self.new
    
    list_stack = [list]
    project_stack = []
    
    line_num = 0
    list_text.each_line do |line|
      line_num += 1
      p = TaskListParser::Project.load(line, last_date)
      if p
        p.line_number = line_num
        if list_stack.last.projects.last && list_stack.last.projects.last.indentation < p.indentation
          list_stack << list_stack.last.projects.last
          puts "Adding #{list_stack.last.name} to list stack"
        elsif list_stack.last.projects.last && list_stack.last.projects.last.indentation > p.indentation
          popped = list_stack.pop
          puts "Removed #{popped.name} from stack"
        end
        list_stack.last.projects << p
        if list_stack.last.is_a?(TaskListParser::Project)
          puts "Added #{p.name} to #{list_stack.last.name}"
        end
        project_stack << p
        if p.is_day?
          last_date = p.date
        end
      elsif list_stack.last.projects.last
        t = TaskListParser::Task.load(line, TaskListParser::CONF[:start_time], list.projects.last)
        if t
          t.line_number = line_num
          if project_stack.last.tasks.last && project_stack.last.tasks.last.indentation < t.indentation
            project_stack << project_stack.last.tasks.last
          elsif project_stack.last.tasks.last && project_stack.last.tasks.last.indentation > t.indentation
            project_stack.pop
          end
          project_stack.last.tasks << t
        else
          last_task = project_stack.last.tasks.last
          last_indentation = last_task ? last_task.indentation : 0
          blank_task = TaskListParser::BlankTask.new(last_indentation)
          blank_task.line_number = line_num
          project_stack.last.tasks << blank_task
          #add a 'blank' task to the list
        end
      end
    end
    
    return list
  end
  
  
  
  attr_reader :projects
  
  def initialize
    @projects = []
  end
  
  
  def to_s
    #re-generate the original list object
  end
  
  def to_html(builder = nil)
    b = builder || Builder::XmlMarkup.new
    
    b.div({:class=>'tl-projectList'}) do |div|
      projects.each do |proj|
        proj.to_html(div)
      end
    end
    
  end
  
  def to_ical
    #geneate iCal formatted list
    
    ical = []
    ical << "BEGIN:VCALENDAR"
    ical << "VERSION:2.0"
    ical << "PRODID:-//alexmek//TaskList//EN"
    
    projects.each do |p|
      ical += p.to_ical
    end
    
    ical << "END:VCALENDAR"
    ical.join("\n")
  end
    
  
end