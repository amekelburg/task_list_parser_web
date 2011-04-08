class List < ActiveRecord::Base




  def to_html
    l = TaskListParser::List.load(content)
    l.to_html
  end

  def to_ical
    l = TaskListParser::List.load(content)
    l.to_ical
  end


  def write_ical
    file_name = "task_list_calendar.ics"
    File.open(file_name, "w+") do |f|
      f.write(self.to_ical)
    end
  end

end
