// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function saving() {
  $(".stateIndicator").addClass('saving').html("Saving...").get(0).value="Saving...";
}

function saved() {
  $(".stateIndicator").removeClass('saving').html("Saved").get(0).value="Saved";
  submitting = false;
}


var lastList = '';
var submitting = false;
var list = null;

function saveUpdateListView(textarea) {
  if (lastList != $(textarea).get(0).value) {
    submitting = true;
    $(textarea).parent("form").find("input[type=submit]").click();
    //updateListView(textarea);
  } else {

  }  
}

function updateListView(textarea) {
  //lastList = $(textarea).get(0).value;
  //list = new List(lastList);
  
  //list.updateViewer($("#view").get(0));
  
}


$(document).ready(function() {
  
  
});

