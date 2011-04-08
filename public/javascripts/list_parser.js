function dayOfTheWeek(dayNum) {
  if (dayNum==0) return "Sunday";
  if (dayNum==1) return "Monday";
  if (dayNum==2) return "Tuesday";
  if (dayNum==3) return "Wednesday";
  if (dayNum==4) return "Thursday";
  if (dayNum==5) return "Friday";
  if (dayNum==6) return "Saturday";
};


function formatDate(date) {
  return dayOfTheWeek(date.getDay()) + " " + (date.getMonth() + 1) + "/" + date.getDate() + " " + date.getFullYear();
}





function List (list) {
  //content can be text or an element
  if (typeof(list)==="string") {
    this.list = list;
    this.listView = null;
    this.calendarView = null;
    this.lines = list.split("\n");
    this.lineCount = this.lines.length;
  } else {
    this.list = $(list).get(0).value;
  }
  this.projects = [];
  this.lastDate = new Date();
  this.build();
}

List.prototype.projectRegExp = /(\s*)(.*):\s*$/;


// d|a * || ((PUB) (date) time) Task Description (hrscomplete/hrsEst) [Project Name]

List.prototype.taskRegExp = /(\s*)([da])?(\s*)(\*+|\d{1,2}:?\d{02}?[aApP]m?:)([^\[\(]*)(\(.*\))?(\[.*\])?/;
//2 = done/assigned
//4 = time
//5 = name
//6 = completed/duration
//7 = assigned project

List.prototype.build = function() {
  var project = null;
  this.lastDate = new Date();
  for (var i=0; i<this.lineCount; i++ ) {
    var line = this.lines[i]
    if (line.trim() != '') {
      projMatch = this.projectRegExp.exec(line);
      if (projMatch != null) {
        //console.log(line, ":: is a Project");
        var preSpace = projMatch[1];
        var name = projMatch[2];
        project = new Project(name, this.lastDate);
        if (project.is_day && project.date != null) {
          this.lastDate = project.date;
        }
        this.projects.push(project);
      } else {
        taskMatch = this.taskRegExp.exec(line);
        if (taskMatch != null) {
          if (project != null) {
            var taskName = taskMatch[5];
            myTask = new Task(taskName);
            myTask.status = taskMatch[2];
            if (!taskMatch[4].match(/\*/)) {
              myTask.time = taskMatch[4];
            } else {
              myTask.setIndentation(taskMatch[4])
            }
            myTask.setEstimate(taskMatch[6]);
            myTask.assignedProject = taskMatch[7]
            project.tasks.push(myTask);
          }
          //console.log(line, ":: is a task")
        } else {
          //console.log(line, ":: is no match");
        }
      }
    }
  }
};

List.prototype.updateViewer = function(element) {
  this.listView = $(element).children("#listView");
  this.calendarView = $(element).children("#calendarView");
  this.listView.html('');
  this.calendarView.html('');

  this.listView.append("<div class='dateProjects projectList'></div>");
  var listViewDates = this.listView.children("div:last");
  this.listView.append("<div class='generalProjects projectList'></div>");
  var listViewProjects = this.listView.children("div:last");

  for(var i=0; i<this.projects.length; i++) {
    var myProject = this.projects[i];
    var myProjectDiv = null;
    
    var projectDuration = myProject.duration();
    var pjString ='';
    if (projectDuration > 0) {
      pjString =" ("+projectDuration+")";
    }
    if (myProject.is_day) {
      listViewDates.append("<div class='project date'></div>");
      myProjectDiv = listViewDates.children("div:last");
      myProjectDiv.append("<h3>" + (formatDate(myProject.date) == formatDate(new Date()) ? 'TODAY' : formatDate(myProject.date)) + pjString + "</h3>");
      
    } else {
      listViewProjects.append("<div class='project'></div>");
      myProjectDiv = listViewProjects.children("div:last");
      myProjectDiv.append("<h3>" + myProject.name + pjString +  "</h3>");
      
    }
    myProjectDiv.append("<ul class='taskList'></ul>");
    var myTaskListList = [myProjectDiv.children("ul:last")];
    var myTaskList = myTaskListList[0];
    var lastTask = null;
    for (var k=0; k<myProject.tasks.length; k++) {
      var myTask = myProject.tasks[k];
      if (lastTask != null) {
        if (myTask.indentation > lastTask.indentation) {
          myTaskList.children("li:last").append("<ul class='subTaskList'></ul>");
          myTaskListList.push(myTaskList.children("li:last").children("ul"));
          myTaskList = myTaskListList[myTaskListList.length - 1];
        } else if (myTask.indentation < lastTask.indentation) {
          myTaskListList.pop();
          myTaskList = myTaskListList[myTaskListList.length - 1];
        }
      } 
      lastTask = myTask;
      var durationHtml = " <span class='duration'>";
      durationHtml += (myTask.completed > 0 ? 'completed ' + myTask.completed + ' of ' : '') + (myTask.duration > 0 ? myTask.duration + 'hrs' : '');
      durationHtml += "</span>";
      myTaskList.append("<li class='"+(myTask.isDone() ? 'done' : (myTask.isAssigned() ? 'assigned' : 'task')) + ' '+ (myTask.time.trim() == '' ? '' : 'timed') +"'><span class='taskName'><span class='time'>"+myTask.time+"</span> " + myTask.name + "</span>"+durationHtml+"</li>")
    }
  }
};


function Project (name, lastDate) {
  this.name = name;
  this.tasks = [];
  this.is_day = false;
  dayMatch = this.dayMatchRegExp.exec(this.name);
  if (dayMatch != null) {
    this.is_day = true;
    this.day_of_the_week = dayMatch[1];
    this.date = dayMatch[3];
    if (this.date == null && typeof(this.day_of_the_week) == "string") {
      var daysAhead = this.getDay() - lastDate.getDay();
      if (daysAhead < 0) daysAhead = daysAhead + 7;
      this.date = new Date(lastDate);
      this.date.setYear(lastDate.getFullYear());
      this.date.setDate(lastDate.getDate() + daysAhead);
      
    }
  } else {
    dateMatch = this.dateMatchRegExp.exec(this.name);
    if (dateMatch != null) {
      this.is_day = true
      this.date = new Date();
      this.date.setMonth(dateMatch[1]-1)
      this.date.setDate(dateMatch[2]);
      this.date.setYear(lastDate.getFullYear());
      if (this.date.getMonth() < lastDate.getMonth() || (this.date.getMonth() == lastDate.getMonth() && this.date.getDate() <= lastDate.getDate())) {
        this.date.setYear(lastDate.getFullYear() + 1);
      }
      if (typeof(dateMatch[3]) != "undefined" && dateMatch[3].trim() != '') {
        var yr = dateMatch[3];
        if (yr.length == 2) yr = "20" + yr;
        this.date.setYear(yr);
      }
    }
  }
  
}

//Todo: needs to match 1st and/or 2nd...not neither...
Project.prototype.dayMatchRegExp = /^((sun|mon|tue|wed|thu|fri|sat)[^\s]*)\s*(\d{1,2}\/\d{1,2}\/?(\d{2})?(\d{2})?)?/i;
Project.prototype.dateMatchRegExp = /^(\d{1,2})\/(\d{1,2})\/?((\d{2})?(\d{2})?)/;

Project.prototype.getDay = function () {
  if (this.day_of_the_week.match(/^sun/i)) return 0;
  if (this.day_of_the_week.match(/^mon/i)) return 1;
  if (this.day_of_the_week.match(/^tue/i)) return 2;
  if (this.day_of_the_week.match(/^wed/i)) return 3;
  if (this.day_of_the_week.match(/^thu/i)) return 4;
  if (this.day_of_the_week.match(/^fri/i)) return 5;
  if (this.day_of_the_week.match(/^sat/i)) return 6;
};


Project.prototype.duration = function () {
  var duration = 0;
  for(var i=0; i<this.tasks.length; i++) {
    duration += this.tasks[i].duration;
  }
  return duration;
}







function Task (name) {
  this.name = name.trim();
  this.indentation=0;
  this.status = '';
  this.time = '';
  this.duration = 0;
  this.completed = 0;
}

Task.prototype.isDone = function () {
  return (typeof(this.status) !== 'undefined') && this.status.trim() == 'd';
};

Task.prototype.isAssigned = function () {
  return (typeof(this.status) !== 'undefined') && this.status.trim() == 'a';
};

Task.prototype.setIndentation = function(stars) {
  stars = stars.trim();
  var starMatch = stars.match(/\*/g);
  if (starMatch != null) {
    this.indentation = starMatch.length - 1;
  }
}

Task.prototype.setEstimate = function(est) {
  if (typeof(est) != 'undefined' && est.trim() != '') {
    try {
      cleanEst = est.replace(/^\(/,'').replace(/\)$/,'');
      var hrs = cleanEst.split('/');
      if (hrs.length == 2 && hrs[1].trim() != '') {
        this.completed = parseInt(hrs[0]);
        this.duration = parseInt(hrs[1]);
      } else {
        this.duration = parseInt(hrs[0]);
      }
      if (isNaN(this.completed) || isNaN(this.duration)) {
        this.completed = 0;
        this.duration = 0;
        throw("NaN");
      }
    } catch(er) {
      this.name += " " + est;
    }
  }
}


