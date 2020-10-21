
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>

<%@ page import="javax.servlet.http.HttpSession"%>
<%@ page import="javax.servlet.http.HttpServletRequest"%>

<%@ page import="java.util.ResourceBundle"%>
    
<%@ page import="org.apache.log4j.Logger"%>
<%@ page import="org.apache.log4j.Level"%>

<%@ page import="edu.wpi.fh2t.utils.*"%>

<% 
session = request.getSession();
ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");
Logger logger = (Logger) session.getAttribute("logger");
logger.setLevel(Level.INFO);
String ServerName = (String) request.getServerName();
//ServerName = "localhost";
logger.info("servername=" + ServerName);

Person currentUser = (Person) session.getAttribute("currentUser");
currentUser.setCurrentRole("Researcher");
String experimentAbbr = (String) session.getAttribute("expAbbr");
String experimentDisplay = (String) session.getAttribute("expDisplay");


logger.setLevel(Level.INFO);
%>
    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><%= rb.getString("title")%></title>
  <link rel="stylesheet" href="css/bootstrap.min.css">
  <link rel="stylesheet" href="css/styles.css">
  <link href='https://fonts.googleapis.com/css?family=Oxygen:400,300,700' rel='stylesheet' type='text/css'>
  <link href='https://fonts.googleapis.com/css?family=Lora' rel='stylesheet' type='text/css'>
  <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.8.1/css/all.css"
    integrity="sha384-50oBUHEmvpQ+1lW4y57PTFmhCaXp0ML5d60M1M7uH2+nqUivzIebhndOJK28anvf" crossorigin="anonymous">

    <!-- jQuery (Bootstrap JS plugins depend on it) -->
    <script src="js/jquery-2.1.4.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    
    <script>

   
    var serverName = "<%=ServerName%>";
    var currentUser = "<%=currentUser.getName()%>";
	var experimentAbbr = "<%=experimentAbbr%>";
	var experimentDisplay = "<%=experimentDisplay%>";
	
    var wideScreen = 0;

    var strVisualizer = "?data=\"Hello\"";
    
	var currentTableNbr = 0;

	var filter = "";
    var currentSchool = "06";
    var currentTeacher = "";
    var currentClassroom = "";
    var currentStudent = "";

    var currentProblem = "";
    var currentView = "";
    var resultsQuery = "";
    
    const REPORTS  = 1;
    const STUDENTS = 2;
    const WORLDS   = 3;
    const PROBLEMS = 4;
    const TRIALS   = 5;
    const EVENTS   = 6;
    const SCHOOLS  = 7;
    const TEACHERS = 8;
    const CLASSROOMS = 9;
         
    var tables = [
    	{"name":"","color":""},
    	{"name":"reports","color":"red"},
    	{"name":"usernames","color":"wheat"},
    	{"name":"worlds","color":"palegreen"},
    	{"name":"problems","color":"lightpink"},
    	{"name":"trials","color":"Orange"},
    	{"name":"events","color":"Orange"},
    	{"name":"schools","color":"paleturquoise"},
    	{"name":"teachers","color":"palegreen"},
    	{"name":"classrooms","color":"lemonchiffon"}
    
    ];
       
    function save() {
      //alert("Save");
    }
    function setFilter() {
    	  	
    	var role = "Researcher";

    	if (role == "Researcher") {
    		filter = experimentAbbr;
    		//alert("setFilter = " + filter);
    	}
    }
    function getStudents() {
      var xmlhttp;
      
      //alert("getStudents()");
      if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
        xmlhttp = new XMLHttpRequest();
      }
      else {// code for IE6, IE5
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
      }
      xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
            $("#shared-work-area").show();
          	document.getElementById("StudentSelection").innerHTML = xmlhttp.responseText;
//	  		if (currentStudent.length == 0) {
//				$("#avgBtn").show();
//				$("#sankeyBtn").show();
//				$("#treeMapBtn").show();
//		        $("#visualizerBtn").show();        
//		        $("#clearBtn").show();        
//			}
//			else {
//				$("#avgBtn").hide();
//				$("#sankeyBtn").hide();			
//				$("#treeMapBtn").hide();			
//		        $("#visualizerBtn").show();        
//		        $("#clearBtn").show();        
//			}
        }
      };

      if (filter.length == 0) {
      	filter = experimentAbbr;
      }
      	//alert("Student filter " + filter);
       	currentTableNbr = STUDENTS;
	
        var cmd = "";
        if (currentProblem == "") {
       		cmd = "GetStudents?tablecolor=" + tables[currentTableNbr].color + "\&filter=" + filter;
        }
        else {
       		cmd = "GetStudents?tablecolor=" + tables[currentTableNbr].color + "\&filter=" + filter + "\&problemId=" + currentProblem;       	
        }
      	xmlhttp.open("GET", cmd, true);
      	xmlhttp.send();
      
    }

    function getStudentView() {

	        $("#shared-work-area").show();
	        $("#worldViewBtn").hide();
	        $("#problemViewBtn").hide();
	        $("#getTeachersBtn").show();
	        $("#getClassroomsBtn").show();
	        $("#getStudentsBtn").show();
        }
    
    
    function getClassrooms() {
        var xmlhttp;
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
            document.getElementById("ClassroomSelection").innerHTML = xmlhttp.responseText;
            getStudents();
          }
        };
        
        if (filter.length == 0) {
        	filter = experimentAbbr;
        }
        //alert("Class filter " + filter);
       	currentTableNbr = CLASSROOMS;
    	
        var cmd = "";
        if (currentProblem == "") {
       		cmd = "GetClassrooms?tablecolor=" + tables[currentTableNbr].color + "\&filter=" + filter;
        }
        else {
       		cmd = "GetClassrooms?tablecolor=" + tables[currentTableNbr].color + "\&filter=" + filter + "\&problemId=" + currentProblem;       	
        }
		xmlhttp.open("GET", cmd, true);
       	xmlhttp.send();
        
      }

 
      function getTeachers() {
          var xmlhttp;
          //alert("getTeachers");

          if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
            xmlhttp = new XMLHttpRequest();
          }
          else {// code for IE6, IE5
            xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
          }
          xmlhttp.onreadystatechange = function () {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
              document.getElementById("TeacherSelection").innerHTML = xmlhttp.responseText;
              getClassrooms();
            }
          };
          
          if (filter.length == 0) {
          	filter = experimentAbbr;
          }
          	//alert("Teacher filter " + filter);
            currentTableNbr = TEACHERS;    	
            var cmd = "";
            if (currentProblem == "") {
           		cmd = "GetTeachers?tablecolor=" + tables[currentTableNbr].color + "\&filter=" + filter;
            }
            else {
           		cmd = "GetTeachers?tablecolor=" + tables[currentTableNbr].color + "\&filter=" + filter + "\&problemId=" + currentProblem;       	
            }
   			//alert(cmd);
   			xmlhttp.open("GET", cmd, true);
         	xmlhttp.send();          
        }
        
        function getSchools() {
            var xmlhttp;
            //alert("getSchools");

            if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
              xmlhttp = new XMLHttpRequest();
            }
            else {// code for IE6, IE5
              xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
            }
            xmlhttp.onreadystatechange = function () {
              if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
                document.getElementById("SchoolSelection").innerHTML = xmlhttp.responseText;
                getTeachers();
              }
            };

            if (filter.length == 0) {
            	filter = experimentAbbr;
            }
            //alert("School filter " + filter);
            currentTableNbr = SCHOOLS;
            var cmd = "";
            if (currentProblem == "") {
           		cmd = "GetSchools?tablecolor=" + tables[currentTableNbr].color + "\&filter=" + filter;
            }
            else {
           		cmd = "GetSchools?tablecolor=" + tables[currentTableNbr].color + "\&filter=" + filter + "\&problemId=" + currentProblem;       	
            }
   			//alert(cmd);
           	xmlhttp.open("GET", cmd, true);
           	xmlhttp.send();
            
          }



    function getProblems() {
        var xmlhttp;
        //alert("getProblems");
        
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
            //alert(xmlhttp.responseText);
            document.getElementById("ProblemSelection").innerHTML = xmlhttp.responseText;
          }
        };
        
        currentTableNbr = PROBLEMS;
       	var cmd = "GetProblems?tablecolor=" + tables[currentTableNbr].color;
       	//alert(cmd);
       	xmlhttp.open("GET", cmd, true);
       	xmlhttp.send();
        
      }

    
    function getProblemView() {

    	$("#shared-work-area").show();


        getProblems();
        currentView = "problemView";

      }
   
    function getTrialId(studentId,problemId) {
        var xmlhttp;
        //alert("getTrialId");
        

        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
        	
              //alert(xmlhttp.responseText);
              
              var temp = xmlhttp.responseText;
              
              var res = temp.split(",");
                            
              document.getElementById("visContent1").innerHTML = "<%= rb.getString("start_state")%>" + ": " + res[1];
              document.getElementById("visContent2").innerHTML = "<%= rb.getString("goal_state")%>"  + ": " + res[2];
              document.getElementById("visContent3").innerHTML = "<%= rb.getString("best_steps")%>"  + ": " + res[3];


			  getTrialEvents(res[0],studentId,problemId);
          }
        };
        
       	var cmd = "GetTrialId?studentId=" + studentId + "\&problemId=" + problemId;
        //alert(cmd);
       	xmlhttp.open("GET", cmd, true);
       	xmlhttp.send();
        
      }
    
    
    function resetTrials(){
    	$('select#trialsSelections option').removeAttr("selected");
    }
   
    function getTrialEvents(trialId,studentId,problemId) {
        var xmlhttp;
        //alert("getTrialEvents");
        
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }

        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
        	
        	//var txt = '[{"name":"John", "age":30, "city":"New York"}]'
        	//var obj = JSON.parse(txt);
            //var line = obj[0].name + ", " + obj[0].age;
            //alert("Test = " + line);
      	
        	//alert(xmlhttp.responseText);
        	
        	//var allData = JSON.parse(xmlhttp.responseText);
        	//document.getElementById("visualizerJSON").value = allData;
	   		//var visualizerForm= document.getElementById("visualizerForm");
	   		//visualizerForm.submit();

              
    	    //allData.forEach(myFunction); 
    	    //function myFunction(d, i, arr) {
    	    	//if (d["expr_ascii"] == null) {
    	    	//}
    	    	//else {
        	    	//var line = d["expr_ascii"];
    	    	//}
    	    //}
   	    	//alert(xmlhttp.responseText);
   	    	var resp = xmlhttp.responseText;
   	    	var iframeLine = "";
   	    	if (resp == "[]") {
   	    		alert("Problem not attempted");
   	    	}
   	    	else {  	
   	    		if (wideScreen == 1) {
 	                $("#visHeaderRow").show();
//		            $("#visContentRow").show();
   	    		    $("#wide-work-area").hide();
   	    		    iframeLine = "<iframe src='http://" + serverName + ":9000/clustervis_condensed.php?username=" + currentUser + "' width = '100%' height = '600' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>"
   	    		    document.getElementById("wideView").innerHTML =	iframeLine;
   	    			$("#wide-work-area").show();
   	    	        $("#screenshotViewBtn").show();
   	    		
   	    			

   	    		}
				if (wideScreen == 0) {
		      		getTrialMetrics(studentId,problemId);
		            $("#visHeaderRow").show();
		            $("#studentMetricsGrid").show();
		            $("#problemMetricsGrid").hide();
		   		    $("#visualizer").hide();
   	    		    iframeLine = "<iframe src='http://" + serverName + ":9000/clustervis.php?username=" + currentUser + "' width = '100%' height = '500' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>";
					//alert(iframeLine);

					document.getElementById("resultsView").innerHTML =	iframeLine;
		   	    	$("#visualizer").show();
   	    	        $("#screenshotViewBtn").show();
   	    		}
   	    	}
    	    
          }
        };
        
        $("#visHeaderRow").hide();
//        $("#visContentRow").hide();
//        $("#gridHeader").hide();
        $("#studentMetricsGrid").hide();
	    $("#visualizer").hide();
    	$("#wide-work-area").show();
    	
    	document.getElementById("wideView").innerHTML = "";
    	document.getElementById("resultsView").innerHTML = "";
    	
       	var cmd = "GetTrialEvents?trialId=" + trialId;
       	//alert(cmd);
       	xmlhttp.open("GET", cmd, true);
       	xmlhttp.timeout = 10000;
       	xmlhttp.send();
      }

    function resetTrialEvents(){
    	$('select#eventsSelections option').removeAttr("selected");
    }

    
	  function fetchMetric(item, index) {
  	    document.getElementById("demo").innerHTML += index + ":" + item + "<br>";
  	  }

     function getProblemHdrs() {
          var xmlhttp;
          //alert("getProblemHdrs");

   
          if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
            xmlhttp = new XMLHttpRequest();
          }
          else {// code for IE6, IE5
            xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
          }
          xmlhttp.onreadystatechange = function () {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
          	  
                //alert(xmlhttp.responseText);
                var hdrs = JSON.parse(xmlhttp.responseText);
   
                //alert(hdrs.start_state);

            	$("#visHeaderRow").show();

                document.getElementById("visContent1").innerHTML = "start_state:" + hdrs.start_state;
                document.getElementById("visContent2").innerHTML = "goal_state:" + hdrs.goal_state;
                document.getElementById("visContent3").innerHTML = "best_step:" + hdrs.best_step;
            }
        };
          
       	var cmd = "GetProblemHdrs?problemId=" + currentProblem;
       	//alert(cmd);
       	xmlhttp.open("GET", cmd, true);
       	xmlhttp.send();
    }
	function getProblemSan(){
        var xmlhttp;
        //alert("getProblemSankey");

        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
            xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
            xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
           	if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
         	   	//alert(xmlhttp.responseText);
  				if (xmlhttp.responseText == "sankeyFiltered") {
  					
    				var problemNbr = currentProblem;
    				if (problemNbr.length == 1) {
    					problemNbr = "00" + problemNbr;
    				}
    				else {
    					if ((problemNbr.length == 2)) {
    						problemNbr = "0" + problemNbr;
    					}	
    				}
    				
    				//iframeLine = "<iframe frameborder='2' scrolling='yes' width='750px' height='500px' src='images/problem_" + problemNbr + "_Sankey_Filtered.png' name='imgbox' id='imgbox'> <p>iframes are not supported by your browser.</p> </iframe>";
    				document.getElementById("sankeyImg").src =	'images/problem_' + problemNbr + '_Sankey_Filtered.png';

    		        $('#sankeyModal').modal('toggle');
  				}
   	           	else {
   	           		alert("Diagram not available.");
    	    		//$("#sankeyWindow").hide();
   	           	}
           }
       };
     	var cmd = "GetProblemSankey?problemId=" + currentProblem;
      	//alert(cmd);
      	xmlhttp.open("GET", cmd, true);
      	xmlhttp.send();
      			

	}  
    function getProblemSankey() {
        var xmlhttp;
        //alert("getProblemSankey");

        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
            xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
            xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
           	if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
         	   	//alert(xmlhttp.responseText);
  				if (xmlhttp.responseText == "sankeyFiltered") {
  					
    				var problemNbr = currentProblem;
    				if (problemNbr.length == 1) {
    					problemNbr = "00" + problemNbr;
    				}
    				else {
    					if ((problemNbr.length == 2)) {
    						problemNbr = "0" + problemNbr;
    					}	
    				}
    				
    				iframeLine = "<iframe frameborder='2' scrolling='yes' width='750px' height='500px' src='images/problem_" + problemNbr + "_Sankey_Filtered.png' name='imgbox' id='imgbox'> <p>iframes are not supported by your browser.</p> </iframe>";
    				document.getElementById("sankeyView").innerHTML =	iframeLine;

    	    		$("#sankeyWindow").show();
  				}
   	           	else {
   	           		alert("Diagram not available.");
    	    		$("#sankeyWindow").hide();
   	           	}
           }
       };
     	var cmd = "GetProblemSankey?problemId=" + currentProblem;
      	//alert(cmd);
      	xmlhttp.open("GET", cmd, true);
      	xmlhttp.send();
   }
       function getProblemTree(){
           var xmlhttp;
           //alert("getProblemTreeMap");

           if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
               xmlhttp = new XMLHttpRequest();
           }
           else {// code for IE6, IE5
               xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
           }
           xmlhttp.onreadystatechange = function () {
              	if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
            	   	//alert(xmlhttp.responseText);
     				if (xmlhttp.responseText == "treeMap") {

        				var problemNbr = currentProblem;
        				if (problemNbr.length == 1) {
        					problemNbr = "00" + problemNbr;
        				}
        				else {
        					if ((problemNbr.length == 2)) {
        						problemNbr = "0" + problemNbr;
        					}	
        				}

        				document.getElementById("sankeyImg").src =	'images/problem_' + problemNbr + '_Treemap.png';

        		        $('#sankeyModal').modal('toggle');
     				}
      	           	else {
      	           		alert("Diagram not available.");
       	    			//$("#treeMapWindow").hide();
      	           	}
              }
          };
            
      	var cmd = "GetProblemTreeMap?problemId=" + currentProblem;
      	//alert(cmd);
      	xmlhttp.open("GET", cmd, true);
      	xmlhttp.send();    	   
       }  
       function getProblemTreeMap() {
           var xmlhttp;
           //alert("getProblemTreeMap");

           if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
               xmlhttp = new XMLHttpRequest();
           }
           else {// code for IE6, IE5
               xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
           }
           xmlhttp.onreadystatechange = function () {
              	if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
            	   	//alert(xmlhttp.responseText);
     				if (xmlhttp.responseText == "treeMap") {

        				var problemNbr = currentProblem;
        				if (problemNbr.length == 1) {
        					problemNbr = "00" + problemNbr;
        				}
        				else {
        					if ((problemNbr.length == 2)) {
        						problemNbr = "0" + problemNbr;
        					}	
        				}

       					iframeLine = "<iframe frameborder='2' scrolling='yes' width='600px' height='500px' src='images/problem_" + problemNbr + "_Treemap.png' name='imgbox' id='imgbox'> <p>iframes are not supported by your browser.</p> </iframe>";
       					document.getElementById("treeMapView").innerHTML =	iframeLine;
       		
       	    			$("#treeMapWindow").show();
     				}
      	           	else {
      	           		//alert("Diagram not available.");
       	    			$("#treeMapWindow").hide();
      	           	}
              }
          };
            
      	var cmd = "GetProblemTreeMap?problemId=" + currentProblem;
      	//alert(cmd);
      	xmlhttp.open("GET", cmd, true);
      	xmlhttp.send();
   }
	  
	  
	  
	  
    function getProblemAvgs() {
        var xmlhttp;
        //alert("getProblemAvgs");

 
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {

       	  
              var metrics = JSON.parse(xmlhttp.responseText);
              //alert(xmlhttp.responseText);
 			if (metrics.Students == 0){
 				$('#studentModal').modal('toggle');
 			}else
 			{
              var body = "";
              for (x in metrics) {
  		        
            	  var theMetric = x.split("~");
            	  if (theMetric[1] == "time_interaction") {
              		  var strMetric = metrics[x];
            		  var theValues = strMetric.split("~");
            		  
                      timeInteraction = parseFloat(theValues[1]);
                      whole = timeInteraction / 1000;
                      var avgTimeInteraction = "" + whole;
                      if (avgTimeInteraction.length > 7) {
                    	  avgTimeInteraction = avgTimeInteraction.substring(0,7)
                      }

              		  body += "<tr><td class='metricCell'>" + theMetric[0] +  "<span class='metrictooltip'>" + theMetric[2] + "</span></td><td>" + avgTimeInteraction + "</td></tr>" ;
            		  
            	  }
            	  else {
            		var strMetric = metrics[x];
            		var theValues = strMetric.split("~");
            		body += "<tr><td class='metricCell'>" + theMetric[0] +  "<span class='metrictooltip'>" + theMetric[2] + "</span></td><td>" + theValues[1] + "</td></tr>" ;
            	  }
            	  //alert(body);
              }
      	  	  document.getElementById("problemMetricsTable").innerHTML = body;
              $("#problemMetricsGrid").show();
              $("#studentMetricsGrid").hide();
              getProblemHdrs();
            //$("#gridHeader").show();
          }
            }
        };

		if (currentProblem.length > 0) {
	       	var cmd = "GetProblemAvgs?problemId=" + currentProblem;
	       	//alert(cmd);
	       	xmlhttp.open("GET", cmd, true);
	       	xmlhttp.send();    
		}
		else {
			alert("<%= rb.getString("please_select_problem")%>");
		}
    }


    function getTrialMetrics(studentId,problemId) {
        var xmlhttp;
        //alert("getTrialMetrics");

 
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
       	  
              var metrics = JSON.parse(xmlhttp.responseText);
              //alert(xmlhttp.responseText);
 
              var body = "";
              for (x in metrics) {
  		        
            	  var theMetric = x.split("~");
            	  if (theMetric[1] == "time_interaction") {
              		  var strMetric = metrics[x];
            		  var theValues = strMetric.split("~");
            		  
                      var timeInteraction = parseFloat(theValues[0]);
                      var whole = timeInteraction / 1000;
                      var strTimeInteraction = "" + whole;

                      timeInteraction = parseFloat(theValues[1]);
                      whole = timeInteraction / 1000;
                      var avgTimeInteraction = "" + whole;
                      if (avgTimeInteraction.length > 7) {
                    	  avgTimeInteraction = avgTimeInteraction.substring(0,7)
                      }

              		  body += "<tr><td class='metricCell'>" + theMetric[0] + "<span class='metrictooltip'>" + theMetric[2] + "</span></td><td>" + strTimeInteraction + "</td><td>" + avgTimeInteraction + "</td></tr>" ;
            		  
            	  }
            	  else {
            		var strMetric = metrics[x];
            		var theValues = strMetric.split("~");
            		body += "<tr><td class='metricCell'>" + theMetric[0] + "<span class='metrictooltip'>" + theMetric[2] + "</span></td><td>" + theValues[0] + "</td><td>" + theValues[1] + "</td></tr>" ;
            	  }
            	  //alert(body);
              }
      	  	  document.getElementById("studentsMetricsTable").innerHTML = body;
            }
        };

//        <td class="metricCell">1, 2 
//        <span class="tooltip">Tooltip</span> 
//    </td> 

        
       	var cmd = "GetTrialMetrics?studentId=" + studentId + "\&problemId=" + problemId;
       	//alert(cmd);
       	xmlhttp.open("GET", cmd, true);
       	xmlhttp.send();
      }

    function downloadFile(filename) {
        var xmlhttp;
        //alert("filename=" + filename);
 
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          	if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
        	  
  		    	var emsg = xmlhttp.getResponseHeader("Content-Disposition");

        	  	if (emsg == "ErrorMsg") {
            		alert("File not found: " + filename);        	          		  
        	  	}
        	  	else {
	        	  	var element = document.createElement('a');
	        	  	element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(xmlhttp.responseText));
	        	  	element.setAttribute('download', filename);
	
	        	  	element.style.display = 'none';
	        	  	document.body.appendChild(element);
	
	        	  	element.click();
	
	        	  	document.body.removeChild(element);
        	  	}
          	} 
        };
        
       	var cmd = "DownloadFile?filename=" + filename;// + "&problemId=" + currentProblem;
       	//alert(cmd);
       	xmlhttp.open("GET", cmd, true);
       	xmlhttp.send();
      }

    function downloadImage(filename){
    	var problemNbr = currentProblem;
		if (problemNbr.length == 1) {
			problemNbr = "00" + problemNbr;
		}
		else {
			if ((problemNbr.length == 2)) {
				problemNbr = "0" + problemNbr;
			}	
		}
		
	  	var element = document.createElement('a');
	  	element.setAttribute('href', 'images/problem_' + problemNbr + '_' + filename);
	  	element.setAttribute('download', 'Problem ' + currentProblem + ' ' + filename);

	  	element.style.display = 'none';
	  	document.body.appendChild(element);

	  	element.click();

	  	document.body.removeChild(element); 
    }

    /* function downloadProblemViz(filename){
	  	var element = document.createElement('a');
	  	element.setAttribute('href', 'pdf/Viz.pdf');
	  	element.setAttribute('download', filename);

	  	element.style.display = 'none';
	  	document.body.appendChild(element);

	  	element.click();

	  	document.body.removeChild(element);    	
    } */

    
    function clearWorkArea() {
		
		
		//currentSchool = "";
		currentTeacher = "";
	    currentClassroom = "";
	    currentStudent = "";

		document.getElementById("resultsView").innerHTML = "";
        $("#visHeaderRow").hide();
	    $("#visualizer").hide();
	    $("#sankeyWindow").hide();
	    $("#treeMapWindow").hide();
	    $("#studentMetricsGrid").hide();
	    $("#problemMetricsGrid").hide();
		$("#wide-work-area").hide();
		$("#world-work-area").hide();    
        $("#problemViewBtn").show();   
	}
	function clearProblemArea() {
		
		currentSchool = "";
		currentTeacher = "";
	    currentClassroom = "";
	    currentStudent = "";
	    currentProblem = "";

	    document.getElementById("SchoolSelection").innerHTML = "";
	    document.getElementById("TeacherSelection").innerHTML = "";
	    document.getElementById("ClassroomSelection").innerHTML = "";
	    document.getElementById("StudentSelection").innerHTML = "";
	    document.getElementById("selectStudent").value = "";
		document.getElementById("resultsView").innerHTML = "";
        $("#visHeaderRow").hide();
	    $("#visualizer").hide();
		$("#sankeyWindow").hide();
		$("#treeMapWindow").hide();
	    $("#studentMetricsGrid").hide();
	    $("#problemMetricsGrid").hide();
        $("#avgBtn").hide();
        $("#sankeyBtn").hide();
        $("#treeMapBtn").hide();
        $("#screenshotViewBtn").hide();
        
        
        
//        $("#visualizerBtn").show();        
//        $("#clearBtn").show();        
        getProblems();
		$("#wide-work-area").hide();
		setFilter();
	        
	}
	
	
	function setupTrialVisualizer() {
					
//		if (currentView == "problemView") {
			var selectStudent = document.getElementById("selectStudent").value;
			if (selectStudent.length > 0 ) {
				currentStudent = selectStudent;
				//document.getElementById("usernamesSelections").selectedIndex = "0";
			}

			if (currentStudent.length > 0) {
				if (currentProblem.length > 0) {
					getTrialId(currentStudent,currentProblem);				
				}
				else {
					alert("<%= rb.getString("please_select_problem")%>");
				}
			}
			else {
				if (currentProblem.length > 0) {
					alert("<%= rb.getString("please_select_student")%>");
				}
				else {
					alert("<%= rb.getString("please_select_problem_student")%>");
				}
			}
//		}
	}
 
    function setSchool() {
    	var x = document.getElementById("schoolsSelections").value;
    	filter = x.substring(0,4);
    	currentSchool = x.substring(0,2);
    	currentTeacher = "";
    	currentClassroom = "";
    	currentStudent = "";
    	document.getElementById("selectStudent").value = filter;
		getTeachers();
      }

	function setTeacher() {
    	var x = document.getElementById("teachersSelections").value;
    	filter = x.substring(0,6);
    	currentSchool = x.substring(2,4);
    	currentTeacher = x.substring(4,6);
    	currentClassroom = "";
    	currentStudent = "";
    	document.getElementById("selectStudent").value = filter;
		getClassrooms();
      }

    function setClassroom() {
    	var x = document.getElementById("classroomsSelections").value;
    	filter = x.substring(0,8);
    	currentSchool = x.substring(2,4);
    	currentTeacher = x.substring(4,6);
    	currentClassroom = x.substring(7,8);
    	currentStudent = "";
    	document.getElementById("selectStudent").value = filter;
    	getStudents();
      }

    function setStudent() {
    	var x = document.getElementById("usernamesSelections").value;
    	currentSchool = x.substring(0,2);
    	currentTeacher = x.substring(2,6);
    	currentClassroom = x.substring(7,8);
    	currentStudent = x;
    	document.getElementById("selectStudent").value = x;
      }

    function setProblem() {
    	var x = document.getElementById("problemsSelections").value;
    	currentProblem = x;
	    $("#screenshotViewBtn").hide();
		getSchools();
		
		document.getElementById("sankeyView").innerHTML = " ";
		$("#sankeyWindow").show();
        $("#sankeyBtn").show();

        document.getElementById("treeMapView").innerHTML = " ";
        $("#treeMapWindow").show();
        $("#treeMapBtn").show();
        
		document.getElementById("problemMetricsTable").innerHTML = " ";        
		$("#avgBtn").show();
      }
    
    function setWideScreen(onoff) {
    	wideScreen = onoff;
    }
    
    /* $("#sankeyView").click(function(){
    	alert("hi");
    });
    $("#sankeyWindow").click(function(){
    	alert("hi");
    });
    $("#imgbox").click(function(){
    	alert("hi");
    });
    /* $("#sankeyView").click(function(){
    	alert("hi");
    }); */
    $(document).ready(function () {
        $("#visualizer").hide();
        $("#sankeyWindow").hide();
        $("#treeMapWindow").hide();
        $("#studentMetricsGrid").hide();
	    $("#problemMetricsGrid").hide();
        $("#visHeaderRow").hide();
        $("#shared-work-area").hide();
        $("#getTrialsBtn").hide();
        $("#getTeachersBtn").hide();
        $("#getClassroomsBtn").hide();
        $("#getStudentsBtn").hide();
        $("#avgBtn").hide();
        $("#sankeyBtn").hide();
        $("#treeMapBtn").hide();
	    $("#screenshotViewBtn").hide();
/* 	    $("#sankeyView").click(function(){
	    	alert("hi");
	    });
	    $("#sankeyWindow").click(function(){
	    	alert("hi");
	    });
	    $("#imgbox").click(function(){
	    	alert("hi");
	    }); */
    	getProblemView();
    	var researcher = "<%= rb.getString("researcher")%>";
    	var dashboard = "<%= rb.getString("dashboard")%>";
    	var title1 = "<h4>" + researcher + " " + dashboard + "</h4>";
    	document.getElementById("ResearchPageTitle").innerHTML = title1;
    	var title2 = "<h4>" + experimentDisplay + "</h4>";
    	document.getElementById("ResearchPageExperiment").innerHTML = title2;

      });

</script>

</head>
<body>
	<header>
    <div class="row">
    	<div id="ResearchPageHeader">
    		<div id="ResearchPageExperiment" class="col-md-4 col-sm-12 col-xs-12v pull-left">	   	    	
    		</div>
    		<div id="ResearchPageTitle" class="col-md-6 col-sm-12 col-xs-12v pull-left">	   
    		</div>
    		<div id="ResearchPageSignoutButton"class="col-md-2 col-sm-12 col-xs-12v pull-right">
              	<a id="Button" href='/fh2tReportingWeb/index.jsp'>
                	<class="hidden-xs pull-right"><%= rb.getString("sign_out")%></a>
    		</div>	
    	</div>
    </div> 
    </header>
    
    
    <div id="viewModal" class="modal fade" role="dialog">
      <div class="modal-dialog modal-lg" role="content">
        <!-- Modal content-->
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">Results of Current Query</h4>
            <button type="button" class="close btn-danger" data-dismiss="modal">&times;</button>
          </div>
          <div class="modal-body">
      		<div class="row">
    			<div class="col-12">
	    			<div id="resultsQuery" class="col-4"></div>
	    		</div>	
    		</div>
	      	<div class="row">
    			<div class="container">
    				<div id="viewer" >
	    			</div>
    			</div>
    		</div>
      		<div class="row">
    			<div class="col-2">
        			<h2></h2>
      			</div>
    			<div class="col-8">
        			<button type="button" class="btn btn-danger btn-lg ml-1 " onclick='close()'>Close</button>
      				<button type="button" class="btn btn-primary btn-lg ml-1 " onclick='close()'>Print</button>
      			</div>
    			<div class="col-2">
        			<h2></h2>
      			</div>
      		</div>
          </div>
        </div>
      </div>
    </div>
<div class="row">
	<div id="shared-work-area">
		<div id="left-panel" class="col-md-8 col-sm-12 col-xs-12v">	   
		   	<div class="row">
			    <div id="selectionPanel" class="container-fluid selectionPanel">
			    	<div id=menus class="col-md-12 col-sm-12 col-xs-12v">
				      	<div id="level1" class="col-md-3 col-sm-5 col-xs-12v">
							<div class="col-3" id="ProblemSelection"></div>
				      	</div>
				      	
				      	<div id="level2" class="col-md-2 col-sm-6 col-xs-12v">
				    		<div class="col-3" id="SchoolSelection"></div>
					   	</div>
				      	    	
				      	<div id="level3" class="col-md-2 col-sm-6 col-xs-12v">
							<div class="col-2" id="TeacherSelection"></div>
				      	</div>
				
				      	<div id="level4" class="col-md-2 col-sm-6 col-xs-12v">
							<div class="col-2" id="ClassroomSelection"></div>
				      	</div>
				      	
				      	<div id="level5" class="col-md-3 col-sm-6 col-xs-12v">
							<div class="col-2" id="StudentSelection"></div>
				      	</div>
			      	</div>
		      	</div>	
			
				<div class="col-md-12">
			    </div>
		    </div>
			<div id="btnrow" class="row">
	    		<div class="col-sm-12">
					<div class="form-group col-md-2">
	  					<input type="text" class="form-control pull-left" id="selectStudent" placeholder="Enter StudentID">
					</div>
	        		<button id="visualizerBtn" type="button" class="offset-1 col-2 btn btn-primary btn-md ml-1 pull-left " onclick='setWideScreen(0);setupTrialVisualizer()'><%= rb.getString("visualize")%></button>
	        		<button id="wideViewBtn"type="button" class="offset-1 col-2 btn btn-primary btn-md ml-1 pull-left hidden" onclick='setWideScreen(1);setupTrialVisualizer()'><%= rb.getString("wide_view")%></button>
					<a id='screenshotViewBtn' href='/fh2tReportingWeb/fh2tScreenshotVisualizer.jsp'  target='_blank' class='btn btn-primary btn-md ml-1' role='button'>Screenshot View</a>
	        		<button id="sankeyBtn"type="button" class="offset-1 col-2 btn btn-primary btn-md ml-1 pull-left " onclick='getProblemSan();'><%= rb.getString("flow_diagram")%></button>
	        		<button id="treeMapBtn"type="button" class="offset-1 col-2 btn btn-primary btn-md ml-1 pull-left " onclick='getProblemTree();'>TreeMap</button>
	        		<button id="avgBtn"type="button" class="offset-1 col-2 btn btn-primary btn-md ml-1 pull-left " onclick='getProblemAvgs();'>Problem Avgs</button>
	        		<button id="clearBtn"type="button" class="btn btn-danger btn-md ml-1 pull-left " onclick='clearProblemArea()'><%= rb.getString("clear")%></button>
	    		</div>
	    		<div class="col-sm-4">
	      			<h3></h3>
	    		</div>
	  		</div>
	  		
		   	<div id="visHeaderRow" class="row">
				<div class="col-md-5 visheader">
					<p id="visContent1"></p>		
				</div>		
				<div class="col-md-4 visheader"> 
					<p id="visContent2"></p>		
				</div>		
				<div class="col-md-3 visheader">
					<p id="visContent3"></p>		
				</div>		
			</div>
		   	<div class="row">
			    <div id="visualizer">
					<div class="col-md-12" id="resultsView" >
					</div>  	
				</div>    
			</div>	  		
			<div>
			   	<div class="row">
				    <div id="spacer" class="container-fluid ">
						<div class="col-md-12"  >
							<p>&nbsp;</p>
						</div>  	
					</div>    
				</div>
			</div>
			<div id="btnrow" class="row">
	    		<div class="col-sm-12">
						<button id="downloadOBtn" type="button"
							class="offset-1 col-2 btn btn-primary btn-sm ml-1 pull-left "
							onclick='downloadFile("aggregation_table_overall_level.csv")'>
							<strong><%=rb.getString("download")%><strong /> <br /><%=rb.getString("overall_level_data")%>
						</button>
						<button id="downloadPBtn" type="button"
							class="offset-1 col-2 btn btn-primary btn-sm ml-1 pull-left "
							onclick='downloadFile("aggregation_table_problem_level.csv")'><%=rb.getString("download")%>
							<br /><%=rb.getString("problem_level_data")%></button>
						<a href="pdf/Viz.pdf" download="Problem Level Visualization">
							<button id="downloadPVBtn" type="button"
								class="offset-1 col-2 btn btn-primary btn-sm ml-1 pull-left "><%=rb.getString("download")%>
								<br /><%=rb.getString("problem_level_vis")%></button>
						</a>
						<button id="downloadSanBtn" type="button"
							class="offset-1 col-2 btn btn-primary btn-sm ml-1 pull-left "
							onclick='downloadImage("Sankey_Filtered.png")'><%=rb.getString("download")%>
							<br /><%=rb.getString("sankey_dia")%></button>
						<button id="downloadTreeBtn" type="button"
							class="offset-1 col-2 btn btn-primary btn-sm ml-1 pull-left "
							onclick='downloadImage("Treemap.png")'><%= rb.getString("download")%>
							<br /><%= rb.getString("tree_map")%></button>
					</div>
	    		<div class="col-sm-4">
	      			<h3></h3>
	    		</div>
	  		</div>
	  		
	  		
	    </div>
		<div id="right-panel" class="col-md-4 col-sm-12 col-xs-12v">       

			

		    <div class="row">
				<div id="studentMetricsGrid" class="col-md-12" >
					
				  <table class="table table-striped table-bordered measuresTable">
				    <thead>
				      <tr>
				        <th><%= rb.getString("measures")%></th>
				        <th><%= rb.getString("student")%></th></th>
				        <th><%= rb.getString("overall_average")%></th></th>
				      </tr>
				    </thead>
				    <tbody id="studentsMetricsTable">
				    </tbody>
				  </table>
				</div>		
				<div id="problemMetricsGrid" class="col-md-12" >
					
				  <table class="table table-striped table-bordered measuresTable">
				    <tbody id="problemMetricsTable">
				    </tbody>
				  </table>
				</div>		
			</div>  	
			
			
		</div>
	</div>
	<div id="wide-work-area">
		   	<div class="row">
			    <div id="wideView" class="container-fluid ">
					<div class="col-md-12"  >
					</div>  	
				</div>    
			</div>
	</div>
	<div id="world-work-area">
		   	<div class="row">
			    <div id="worldView" class="container-fluid ">
					<div class="col-md-12"  >
					</div>  	
				</div>    
			</div>
	</div>
		   	<div class="row">
			    <div id="sankeyWindow">
					<div class="col-md-7" id="sankeyView" >
						<p>&nbsp;</p>					
					</div>  	
				</div>    
			    <div id="treeMapWindow">
					<div class="col-md-5" id="treeMapView" >
						<p>&nbsp;</p>					
					</div>  	
				</div>    
			</div>	  		

	<div>
		   	<div class="row">
			    <div id="spacer" class="container-fluid ">
					<div class="col-md-12"  >
						<p>&nbsp;</p>
					</div>  	
				</div>    
			</div>
	</div>
	
</div>

		<!-- Modal -->
		<div class="modal fade" id="sankeyModal" tabindex="-1" role="dialog" >
		  <div class="modal-dialog modal-dialog-centered" style = "left:35%" role="content">
		          <img id = "sankeyImg" width='1000px' height='600px'></img>
		      <!-- Modal content-->
<!-- 		      <div class="modal-content">
		        <div class="about-modal-body"">
		        </div>
		      </div> -->
		  </div>
		</div>
		<div class="modal fade" id="studentModal" tabindex="-1" role="dialog" >
		  <div class="modal-dialog modal-dialog-centered" role="content">
		      <div class="modal-content">
		        <div class="modal-header">
		          <h4 class="about-modal-header text-center">Researcher Dashboard</h4>
		        </div>
		        <div class="about-modal-body"">
		        <p></p>
		          <p>No students have completed the problem.</p>
		          <p></p>
		        </div>
		      </div>

		  </div>
		</div>
    <div class="footer">
      <div class="container">
        <div class="row">
          <div class="col-xs-12 text-center">
            <p class="glyphicon glyphicon-copyright-mark copyright"><%= rb.getString("copyright")%></p>
          </div>
        </div>
      </div>
    </div>



</body>

</html>