require 'rubygems'
require 'builder'
module TaskListParser
  
  
  CONF = {
    :done=>"d",
    :assigned=>"a",
    :task=>'\*',
    :sub_task=>'\*',
    :sub_project=>"\t",
    :start_time=>Time.parse("9:00")
  }
  
  
  
  module TaskListLine

    attr_accessor :line_number, :list_id
    
    def uid
      "#{list_id}-#{line_number}"
    end
    
    def blank?
      false
    end
    
  end
  
end