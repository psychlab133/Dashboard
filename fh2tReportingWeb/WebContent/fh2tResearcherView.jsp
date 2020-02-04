<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>

<%@ page import="javax.servlet.http.HttpSession"%>
<%@ page import="javax.servlet.http.HttpServletRequest"%>;

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
logger.info("servername=" + ServerName);

Person currentUser = (Person) session.getAttribute("currentUser");
currentUser.setCurrentRole("Researcher");
//String ExperimentAbbr = (String) session.getAttribute("ExperimentAbbr");

logger.setLevel(Level.DEBUG);
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
    <script src="js/script.js"></script>
    
<% 
if (logger.isDebugEnabled()) {
%>
<script>
	function debugAlert(msg) {
		alert(msg);
	}
</script>
<%	
}
else {
%>
<script>
function debugAlert(msg) {
		var amsg = msg;
	}
</script>	
<%
}
%>    
    <script>

    
    var serverName = "<%= ServerName %>";
    var currentUser = "<%=currentUser.getName()%>";

    var wideScreen = 0;

    var strVisualizer = "?data=\"Hello\"";
    
	var currentTableNbr = 0;
    var currentLevel = "";

	var filter = "";
	var ExperimentAbbr = "FS";
    var currentSchool = "06";
    var currentTeacher = "";
    var currentClassroom = "";
    var currentStudent = "";

    var currentProblem = "";
    var currentView = "";
    
    function Create2DArray(rows) {
    	var arr = [];

    	for (var i=0;i<rows;i++) {
    	   arr[i] = [];
    	}
 		return arr;
    }
    
    var resultsQuery = "";
    
    const REPORTS  = 1;
    const STUDENTS = 2;
    const WORLDS   = 3;
    const PROBLEMS = 4;
    const TRIALS   = 5;
    const EVENTS   = 6;
    const TEACHERS = 7;
    const CLASSROOMS  = 8;
    
    const MAX_TABLES = 5;
    
    var levelTableNbr = [0,0,0,0,0,0];
    //var tableNames = ["", "usernames", "worlds", "problems","attempts"];
    //var tableColors = ["", "Teal", "DarkSeaGreen", "Coral","Orange"];
      
    var selectedColumnsArray = Create2DArray(6);
    var selectedOrderArray = Create2DArray(6);
    var selectedGroupArray = Create2DArray(6);

    var tables = [
    	{"name":"","color":"","keyColumn":""},
    	{"name":"reports","color":"red","keyColumn":"reports.ID"},
    	{"name":"usernames","color":"wheat","keyColumn":"usernames.ID"},
    	{"name":"worlds","color":"palegreen","keyColumn":"worlds.ID"},
    	{"name":"problems","color":"lightpink","keyColumn":"problems.ID"},
    	{"name":"trials","color":"Orange","keyColumn":""},
    	{"name":"events","color":"Orange","keyColumn":""},
    	{"name":"classrooms","color":"lemonchiffon","keyColumn":""},
    	{"name":"teachers","color":"paleturquoise","keyColumn":""}
    
    ];
    
    function clearColumnsArray(nbr) {
    	for (i=0;i<25;i++) {
    		selectedColumnsArray[nbr][i] = "";
    	}
    	
    }
    function clearOrderArray(nbr) {
    	for (i=0;i<25;i++) {
    		selectedOrderArray[nbr][i] = "";
    	}
    	
    }
    function clearGroupArray(nbr) {
    	for (i=0;i<25;i++) {
    		selectedGroupArray[nbr][i] = "";
    	}
    	
    }

    for (j=1;j<6;j++) {
    	clearColumnsArray(j);
    	clearOrderArray(j);
    	clearGroupArray(j);
    }
    
	</script>

<script>

    function save() {
      //alert("Save");
    }
   
    function getNextLevel(tableNbr) {
    	var levelName = "";
    	
    	var i=1;
		for (i = 1; i <= MAX_TABLES; i++) {
			if (tableNbr == levelTableNbr[i]) {
				alert("Table already selected");
				return "";
			}
		}

    	if (document.getElementById("level1Selection").innerHTML == "") {
    		levelTableNbr[1] = tableNbr;
    		levelName = "level1Selection";
    	}
    	else if (document.getElementById("level2Selection").innerHTML == "") {
    		levelTableNbr[2] = tableNbr;
    		levelName = "level2Selection";
    	}
    	else if (document.getElementById("level3Selection").innerHTML == "") {
    		levelTableNbr[3] = tableNbr;
    		levelName = "level3Selection";
    	}
    	else if (document.getElementById("level4Selection").innerHTML == "") {
    		levelTableNbr[4] = tableNbr;
    		levelName = "level4Selection";
    	}
    	else if (document.getElementById("level5Selection").innerHTML == "") {
    		levelTableNbr[5] = tableNbr;
    		levelName = "level5Selection";
    	}
    	//alert("level1table=" + levelTableNbr[1]);
    	//alert("level2table=" + levelTableNbr[2]);
    	//alert("level3table=" + levelTableNbr[3]);
		if (levelName.length == 0) {
			alert("Too many tables selected");
		}
    	return levelName;
    }

    function getLevelNbr(levelSelection) {
    	var x = 0;
    	if (levelSelection == "level1Selection") {
    		x = 1;
    	}
    	if (levelSelection == "level2Selection") {
    		x = 2;
    	}
    	if (levelSelection == "level3Selection") {
    		x = 3;
    	}
    	if (levelSelection == "level4Selection") {
    		x = 4;
    	}
    	if (levelSelection == "level5Selection") {
    		x = 5;
    	}
    	return x;
    }

    function setFilter() {
    	  	
    	var role = "Researcher";

    	if (role == "Researcher") {
    		filter = ExperimentAbbr;
    		//alert(filter);
    	}
    }

    function getReport() {
        var xmlhttp;
		alert("getReport");
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
            alert(xmlhttp.responseText);


            var url = "src='http://serverName:8080/fh2tReportingWeb/vbarchart.jsp";
            var params = xmlhttp.responseText;
            reportOptions = params.split(":");
            
            var strGraphs = reportOptions[0];
            var graphs = Number(strGraphs);
            var leftData = reportOptions[1];
            var rightData = reportOptions[2];
                   
            var str = ""; 

            if (strGraphs === "1") {
                if ((leftData.length > 0) && (rightData.length > 0)){
                	// comarison graph
        			str = document.getElementById("worldView").innerHTML = "<iframe " + url + "?graphs=" + strGraphs + "&ldata=" + leftData + "&rdata=" + rightData + "' width = '100%' height = '600' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>";
        		}
        		else {
        			if (leftData.length > 0) {
        				// single graph in left panel
        				str = "<iframe " + url + "?graphs=" + strGraphs + "&ldata=" + leftData + "' width = '100%' height = '600' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>";
        			}
        			else {
        				// single graph in right panel
        				str = "<iframe " + url + "?graphs=" + strGraphs + "&rdata=" + rightData + "' width = '100%' height = '600' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>";
	        		}
        		}
        	}
            else {
            	if (strGraphs === "2"){
    				str = document.getElementById("worldView").innerHTML = "<iframe " + url + "?graphs=" + strGraphs + "&ldata=" + leftData + "&rdata=" + rightData + "' width = '100%' height = '600' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>";            	
            	}
            	else {
            		// Run fh2t
            		str = "<iframe src='http://graspablemath.com/projects/fh2t' width = '100%' height = '600' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>";
            	}
          	}
            alert(str);
            document.getElementById("worldView").innerHTML = str;

//			document.getElementById("worldView").innerHTML = "<iframe src='http://localhost:8080/fh2tReportingWeb/vbarchart.jsp?graphs=" + graphs + "&ldata=" + leftData + "&rdata=" + rightData + "' width = '100%' height = '600' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>";
//left			document.getElementById("worldView").innerHTML = "<iframe src='http://localhost:8080/fh2tReportingWeb/vbarchart.jsp?graphs=" + graphs + "&ldata=" + leftData + "' width = '100%' height = '600' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>";
//right			document.getElementById("worldView").innerHTML = "<iframe src='http://localhost:8080/fh2tReportingWeb/vbarchart.jsp?graphs=" + graphs + "&rdata=" + rightData + "' width = '100%' height = '600' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>";
//			document.getElementById("worldView").innerHTML = "<iframe src='http://localhost:8080/fh2tReportingWeb/vbarchart.jsp?side=left' width = '100%' height = '600' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>";
    		$("#world-work-area").show();
            $("#worldView").show();    
          }
        };
        //alert("Report selection:" + document.getElementById("reportsSelections").value);
      	var cmd = "GetReport?reportname=" + document.getElementById("reportsSelections").value;
       	xmlhttp.open("GET", cmd, true);
       	xmlhttp.send();
        
      }
    
    
    function getReports() {
        var xmlhttp;
        //var currentLevel = "";
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
            document.getElementById(currentLevel).innerHTML = xmlhttp.responseText;
            //alert(xmlhttp.responseText);
          }
        };
        
        currentTableNbr = REPORTS;
        currentLevel = getNextLevel(currentTableNbr);
        if (currentLevel.length > 0) {
        	var cmd = "GetReports?tablecolor=" + tables[currentTableNbr].color + "\&level=" + getLevelNbr(currentLevel);
        	xmlhttp.open("GET", cmd, true);
        	xmlhttp.send();
        }
        
      }

      function resetReports(){
      	$('select#reportsSelections option').removeAttr("selected");
      }
      
     
    function getStudents() {
      var xmlhttp;
      
      //alert("getStudents()");
      //var currentLevel = "";
      if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
        xmlhttp = new XMLHttpRequest();
      }
      else {// code for IE6, IE5
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
      }
      xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
            $("#shared-work-area").show();
            $("#worldViewBtn").hide();
            $("#problemViewBtn").hide();
            $("#getTeachersBtn").show();
            $("#getClassroomsBtn").show();
            $("#getStudentsBtn").show();
          document.getElementById(currentLevel).innerHTML = xmlhttp.responseText;
        }
      };
      currentTableNbr = STUDENTS;
      currentLevel = getNextLevel(currentTableNbr);
      
      //alert(filter);
      if (currentLevel.length > 0) {
      	var cmd = "GetStudents?tablecolor=" + tables[currentTableNbr].color + "\&level=" + getLevelNbr(currentLevel) + "\&filter=" + filter;
		//alert(cmd);
      	xmlhttp.open("GET", cmd, true);
      	xmlhttp.send();
      }
      
    }

    function resetStudents(){
    	$('select#usernamesSelections option').removeAttr("selected");
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
            document.getElementById(currentLevel).innerHTML = xmlhttp.responseText;
          }
        };
        
        alert(filter);
        currentTableNbr = CLASSROOMS;
        currentLevel = getNextLevel(currentTableNbr);
        if (currentLevel.length > 0) {
        	var cmd = "GetClassrooms?tablecolor=" + tables[currentTableNbr].color + "\&level=" + getLevelNbr(currentLevel) + "\&filter=" + filter;
			//alert(cmd);
        	xmlhttp.open("GET", cmd, true);
        	xmlhttp.send();
        }
        
      }

      function resetClassrooms(){
      	$('select#classroomsSelections option').removeAttr("selected");
      }
      
      function getTeachers() {
          var xmlhttp;
          //alert("getTeachers");
          //var currentLevel = "";
          if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
            xmlhttp = new XMLHttpRequest();
          }
          else {// code for IE6, IE5
            xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
          }
          xmlhttp.onreadystatechange = function () {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
              document.getElementById(currentLevel).innerHTML = xmlhttp.responseText;
            }
          };
          
          //alert(filter);
          currentTableNbr = TEACHERS;
          currentLevel = getNextLevel(currentTableNbr);
          if (currentLevel.length > 0) {
          	var cmd = "GetTeachers?tablecolor=" + tables[currentTableNbr].color + "\&level=" + getLevelNbr(currentLevel) + "\&filter=" + filter;
  			//alert(cmd);
          	xmlhttp.open("GET", cmd, true);
          	xmlhttp.send();
          }
          
        }

        function resetTeachers(){
        	$('select#teacherSelections option').removeAttr("selected");
        }
        


      
    function getWorlds() {
	
    	var xmlhttp;
	                
	    currentLevel = "";
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
            xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
            xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
  	        	//alert(xmlhttp.responseText);
   	            document.getElementById(currentLevel).innerHTML = xmlhttp.responseText;
   			}
        };
	                      
        currentTableNbr = WORLDS;
        currentLevel = getNextLevel(currentTableNbr);
        if (currentLevel.length > 0) {
        	var cmd = "GetWorlds?tablecolor=" + tables[currentTableNbr].color + "\&level=" + getLevelNbr(currentLevel);
//        	alert(cmd);
        	xmlhttp.open("GET", cmd, true);
        	xmlhttp.send();
        }
        
      }

    
    function getWorldView() {
        var xmlhttp;
//        alert("getWorldView()");
        currentLevel = "";
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
	            $("#problemViewBtn").hide();
	            $("#studentViewBtn").hide();
	            $("#getWorldsBtn").show();
	            
	            $("#shared-work-area").show();
	            
	            $("#wideView").hide();
	            currentView = "worldView";
//	        	alert(xmlhttp.responseText);

	            document.getElementById(currentLevel).innerHTML = xmlhttp.responseText;
			}
        };
        
        currentTableNbr = REPORTS;
        currentLevel = getNextLevel(currentTableNbr);
        if (currentLevel.length > 0) {
        	var cmd = "GetReports?tablecolor=" + tables[currentTableNbr].color + "\&level=" + getLevelNbr(currentLevel);
        	//alert(cmd);
        	xmlhttp.open("GET", cmd, true);
        	xmlhttp.send();
        }
        
      }
   
    
    function resetWorlds(){
    	$('select#worldsSelections option').removeAttr("selected");
    }
    

    
    function getProblems() {
        var xmlhttp;
        //alert("getProblems");
        
        currentLevel = "";
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
            //alert(xmlhttp.responseText);
            document.getElementById(currentLevel).innerHTML = xmlhttp.responseText;
          }
        };
        
        currentTableNbr = PROBLEMS;
        currentLevel = getNextLevel(currentTableNbr);
        if (currentLevel.length > 0) {
        	var cmd = "GetProblems?tablecolor=" + tables[currentTableNbr].color + "\&level=" + getLevelNbr(currentLevel);
        	//alert(cmd);
        	xmlhttp.open("GET", cmd, true);
        	xmlhttp.send();
        }
        
      }

    
    function getProblemView() {

    	$("#shared-work-area").show();
        $("#worldViewBtn").hide();
        $("#getWorldsBtn").hide();
        $("#studentViewBtn").hide();
        $("#getTeachersBtn").show();
        $("#getClassroomsBtn").show();
        $("#getStudentsBtn").show();

        getProblems();
        currentView = "problemView";

      }
   
    
    function resetProblems(){
    	$('select#problemsSelections option').removeAttr("selected");
    }
    
    
    function getTrials() {
        var xmlhttp;
        //alert("getTrials");
        
        currentLevel = "";
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
        	
              //alert(xmlhttp.responseText);

              //var obj = JSON.parse(xmlhttp.responseText);
              
              //var myArr = obj.trials;
              
              //alert("after JSONParse");

              //alert(myArr[0]["start_state"]);
              
            document.getElementById(currentLevel).innerHTML = "<p>" + xmlhttp.responseText + "</p>"
          }
        };
        
        currentTableNbr = TRIALS;
        currentLevel = getNextLevel(currentTableNbr);
        if (currentLevel.length > 0) {
        	var cmd = "GetTrials?tablecolor=" + tables[currentTableNbr].color + "\&level=" + getLevelNbr(currentLevel);
        	//alert(cmd);
        	xmlhttp.open("GET", cmd, true);
        	xmlhttp.send();
        }
        
      }

    function getTrialId(studentId,problemId) {
        var xmlhttp;
        //alert("getTrialId");
        
        currentLevel = "";
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
                            
              document.getElementById("visContent1").innerHTML = res[1];
              document.getElementById("visContent2").innerHTML = res[2];
              document.getElementById("visContent3").innerHTML = res[3];


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
        
        currentLevel = "";
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
		            $("#visContentRow").show();
   	    		    $("#wide-work-area").hide();
   	    		    iframeLine = "<iframe src='http://" + serverName + ":9000/clustervis.php?username=" + currentUser + "' width = '100%' height = '600' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>";
					//alert(iframeLine);
   	    			//document.getElementById("wideView").innerHTML = "<iframe src='http://" + serverName + ":9000/clustervis.php?username=Frank' width = '100%' height = '600' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>";
   	    	    	document.getElementById("wideView").innerHTML =	iframeLine;
   	    			$("#wide-work-area").show();
   	    			
   	    		}
   	    		else {
		      		getTrialMetrics(studentId,problemId);
		
		              $("#visHeaderRow").show();
		              $("#visContentRow").show();
		              $("#gridHeader").show();
		              $("#metricsGrid").show();
		
		   		    $("#visualizer").hide();
   	    		    iframeLine = "<iframe src='http://" + serverName + ":9000/clustervis.php?username=" + currentUser + "' width = '100%' height = '600' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>";
		   			//document.getElementById("resultsView").innerHTML = "<iframe src='http://" + serverName + ":9000/clustervis.php?username=Frank' width = '100%' height = '600' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>";
					//alert(iframeLine);
		   			document.getElementById("resultsView").innerHTML =	iframeLine;
		   	    	$("#visualizer").show();
   	    		}
   	    	}
    	    
          }
        };
        
        $("#visHeaderRow").hide();
        $("#visContentRow").hide();
        $("#gridHeader").hide();
        $("#metricsGrid").hide();
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

//        	  metricNames.forEach(index,item) {
//        		  alert(index + ":" + item);
//                  document.getElementById(item).innerHTML = metrics[item];
//        	  }
        	  
//alert(xmlhttp.responseText);
        	  
              var metrics = JSON.parse(xmlhttp.responseText);
     
              for (x in metrics) {
            	  if (x == "time_interaction") {
                      var timeInteraction = parseFloat(metrics.time_interaction);
                      var whole = timeInteraction / 1000;
                      var strTimeInteraction = "" + whole;
                      document.getElementById("time_interaction").innerHTML = strTimeInteraction;
            		  
            	  }
            	  else {
            	  	document.getElementById(x).innerHTML = metrics[x];
            	  }
              }
            }
        };
        
       	var cmd = "GetTrialMetrics?studentId=" + studentId + "\&problemId=" + problemId;
       	//alert(cmd);
       	xmlhttp.open("GET", cmd, true);
       	xmlhttp.send();
      }


    function getColumns(colNbr) {
        var xmlhttp;
      		
        currentTableNbr = levelTableNbr[colNbr];
        
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
            //alert("ready");
            var raw = xmlhttp.responseText;
            var ins = tables[currentTableNbr].name + "ColumnSelections"
            response  = raw.replace("Options", ins);
            document.getElementById("columnSelect").innerHTML = response;
            ins = tables[currentTableNbr].name + "OrderSelections"
            response  = raw.replace("Options", ins);
            document.getElementById("columnOrder").innerHTML = response;
            ins = tables[currentTableNbr].name + "GroupSelections"
            response  = raw.replace("Options", ins);
            document.getElementById("columnGroup").innerHTML = response;
            $('#columnsModal').modal('toggle');
          }
        };
        var cmd = "GetColumns?tablename=" + tables[currentTableNbr].name + "\&tablecolor=" + tables[currentTableNbr].color;
        xmlhttp.open("GET", cmd, true);
        xmlhttp.send();
      }

	function saveSelectedColumns() {

		var level = getLevelNbr(currentLevel);	
        currentTableNbr = levelTableNbr[level];
        debugAlert("currentTableNbr=" + currentTableNbr);
		var selectName = tables[currentTableNbr].name + "ColumnSelections";
		debugAlert(selectName);
		var x = document.getElementById(selectName).options.length;

		clearColumnsArray(currentTableNbr);
		
		var first = true;
		for (i = 0; i < x; i++) {
			//debugAlert("i=" + i + document.getElementById(selectName).options[i].text)
			if (document.getElementById(selectName).options[i].selected == true) {
				selectedColumnsArray[currentTableNbr][i] = document.getElementById(selectName).options[i].text;
				debugAlert(selectedColumnsArray[currentTableNbr][i]);
			}
		}
	}
	
	function saveOrderColumns() {

		var level = getLevelNbr(currentLevel);	
        currentTableNbr = levelTableNbr[level];
        debugAlert("currentTableNbr=" + currentTableNbr);
		var orderName = tables[currentTableNbr].name + "OrderSelections";
		debugAlert(orderName);
		var x = document.getElementById(orderName).options.length;

		clearOrderArray(currentTableNbr);
		
		var first = true;
		var j=0;
		for (i = 0; i < x; i++) {
			//debugAlert("i=" + i + document.getElementById(orderName).options[i].text)
			if (document.getElementById(orderName).options[i].selected == true) {
				selectedOrderArray[currentTableNbr][j] = document.getElementById(orderName).options[i].text;
				debugAlert(selectedOrderArray[currentTableNbr][j]);
				j = j + 1;
			}
		}
	}

	function saveGroupColumns() {
		
		var level = getLevelNbr(currentLevel);	
        currentTableNbr = levelTableNbr[level];
		var groupName = tables[currentTableNbr].name + "GroupSelections";
		var x = document.getElementById(groupName).options.length;

		clearGroupArray(currentTableNbr);
		
		var first = true;
		var j=0;
		for (i = 0; i < x; i++) {
			if (document.getElementById(groupName).options[i].selected == true) {
				selectedGroupArray[currentTableNbr][j] = document.getElementById(groupName).options[i].text;
				debugAlert(selectedGroupArray[currentTableNbr][j]);
				j = j + 1;
			}
		}
	}

	function clearWorkArea() {
		
    	var i=1;
    	var levelName = "";
		for (i = 1; i <= MAX_TABLES; i++) {
			levelTableNbr[i] = 0;
			levelName = "level" + i + "Selection";
			document.getElementById(levelName).innerHTML = "";
			clearColumnsArray(i);
			clearOrderArray(i);
			clearGroupArray(i);
		}
		
		//currentSchool = "";
		currentTeacher = "";
	    currentClassroom = "";
	    currentStudent = "";

		document.getElementById("resultsView").innerHTML = "";
        $("#visHeaderRow").hide();
        $("#visContentRow").hide();
	    $("#visualizer").hide();
	    $("#metricsGrid").hide();
        setFilter();
		$("#wide-work-area").hide();
		$("#world-work-area").hide();
	    
        $("#problemViewBtn").show();
        $("#worldViewBtn").show();
        $("#studentViewBtn").show();
        $("#getTeachersBtn").hide();
        $("#getClassroomsBtn").hide();
        $("#getStudentsBtn").hide();
        $("#getWorldsBtn").hide();

	    
	}
	function clearProblemArea() {
		
    	var i=1;
    	var levelName = "";
    	//start at 2 to leave the problem list displayed
		for (i = 2; i <= MAX_TABLES; i++) {
			levelTableNbr[i] = 0;
			levelName = "level" + i + "Selection";
			document.getElementById(levelName).innerHTML = "";
			clearColumnsArray(i);
			clearOrderArray(i);
			clearGroupArray(i);
		}
		
		//currentSchool = "";
		currentTeacher = "";
	    currentClassroom = "";
	    currentStudent = "";

		//document.getElementById("currentQuery").innerHTML = "";
		//document.getElementById("resultsQuery").innerHTML = "";
		document.getElementById("resultsView").innerHTML = "";
        $("#visHeaderRow").hide();
        $("#visContentRow").hide();
	    $("#visualizer").hide();
	    $("#metricsGrid").hide();
        //getProblems();
		$("#wide-work-area").hide();
		setFilter();
	        
	}

	
	</script>
<script>

	function setupTrialVisualizer() {
				
		if (currentView == "problemView") {
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
		}
	}
 
    function setSchool() {
    	//var x = document.getElementById("schoolsSelections").value;
    	currentSchool = x.substring(0,2);
    	currentTeacher = "";
    	currentClassroom = "";
    	currentStudent = "";
		//alert("set" + filter); 		
      }

	function setTeacher() {
    	var x = document.getElementById("teachersSelections").value;
    	filter = x.substring(0,6);
    	currentSchool = x.substring(2,4);
    	currentTeacher = x.substring(4,6);
    	currentClassroom = "";
    	currentStudent = "";
		//alert("set" + filter); 		
      }

    function setClassroom() {
    	var x = document.getElementById("classroomsSelections").value;
    	filter = x.substring(0,8);
    	currentSchool = x.substring(2,4);
    	currentTeacher = x.substring(4,6);
    	currentClassroom = x.substring(7,8);
    	currentStudent = "";
      }

    function setStudent() {
    	var x = document.getElementById("usernamesSelections").value;
    	currentSchool = x.substring(0,2);
    	currentTeacher = x.substring(2,6);
    	currentClassroon = x.substring(7,8);
    	currentStudent = x;
		//alert("set" + filter); 		
      }

    function setProblem() {
    	var x = document.getElementById("problemsSelections").value;
    	currentProblem = x;
      }
    
    function setWideScreen(onoff) {
    	wideScreen = onoff;
    }
    
    

    
    $(document).ready(function () {
        $("#visualizer").hide();
        $("#metricsGrid").hide();
        $("#gridHeader").hide();
        $("#visHeaderRow").hide();
        $("#visContentRow").hide();
        $("#shared-work-area").hide();
        $("#getTrialsBtn").hide();
        $("#getTeachersBtn").hide();
        $("#getClassroomsBtn").hide();
        $("#getStudentsBtn").hide();

        //getProblems();
        setFilter();
      });

    function toggleColumnModal() {
    	$('#columnsModal').modal('toggle')
    }
</script>

</head>
<body>
    <header>
      <nav id="header-nav" class="navbar navbar-default">
        <div class="container">
          <div class="navbar-header">

            <div class="navbar-brand">
              <a href="ResearcherView.jsp">
                <h4><%= rb.getString("researcher")%> <%= rb.getString("dashboard")%></h4>
              </a>
            </div>

            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#collapsable-nav">
              <span class="sr-only">Toggle navigation</span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
          </div>

          <div id="collapsable-nav" class="collapse navbar-collapse">
            <ul id="nav-list" class="nav navbar-nav navbar-left">
              <li id="problemViewBtn" onclick='getProblemView()'>
                <a><class="hidden-xs"><strong><%= rb.getString("problem_view")%></strong></a>
              </li>
              <li id="worldViewBtn" onclick='getWorldView()'>
                <a><class="hidden-xs"><strong><%= rb.getString("world_view")%></strong></a>
              </li>
              <li id="studentViewBtn" onclick='getStudentView()'>
                <a> <class="hidden-xs"><strong><%= rb.getString("student_view")%></strong></a>
              </li>
              <li id="getTrialsBtn" onclick='getTrials()'>
                <a><class="hidden-xs"><%= rb.getString("trials")%></a>
              </li>
              <li id="getWorldsBtn" onclick='getWorlds()'>
                <a><class="hidden-xs"><%= rb.getString("worlds")%></a>
              </li>
              <li id="getTeachersBtn" onclick='getTeachers()'>
                <a><class="hidden-xs"><%= rb.getString("teachers")%></a>
              </li>
              <li id="getClassroomsBtn" onclick='getClassrooms()'>
                <a><class="hidden-xs"><%= rb.getString("classrooms")%></a>
              </li>
              <li id="getStudentsBtn" onclick='getStudents()'>
                <a> <class="hidden-xs"><%= rb.getString("students")%></a>
              </li>
              <li id="restart" onclick='clearWorkArea()'>
                <a> <class="hidden-xs"><strong><%= rb.getString("restart")%></strong></a>
              </li>
             <li>
              <a id="Button" href='/fh2tReportingWeb/index.jsp'>
                <class="hidden-xs"><%= rb.getString("sign_out")%></a>
             </li>
            </ul><!-- #nav-list -->
          </div><!-- .collapse .navbar-collapse -->
        </div><!-- .container -->
      </nav><!-- #header-nav -->

    </header>
    
    <div id="columnsModal" class="modal" role="dialog">
      <div class="modal-dialog modal-lg" role="content">
        <!-- Modal content-->
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title"><%= rb.getString("select_columns")%></h4>
            <button type="button" class="close btn-danger" data-dismiss="modal">&times;</button>
          </div>
          <div class="modal-body">
            <form>
              <div id="columnRow" class="form-row">
    			<div class="col-md-4">
    				<div id="columnSelect">
	    			</div>
                	<div class="col-md-3 offset-md-4"><button type="button" class=" btn btn-primary btn-md ml-auto" onclick='saveSelectedColumns()'><%= rb.getString("select")%></button>  </div>
    			</div>
    			<div class="col-md-4">
    				<div id="columnOrder">
	    			</div>
                	<div class="col-md-3 offset-md-4"><button type="button" class=" btn btn-primary btn-md ml-auto" onclick='saveOrderColumns()'><%= rb.getString("order")%></button>  </div>
    			</div>
    			<div class="col-md-4">
    				<div id="columnGroup">
	    			</div>
                	<div class="col-md-3 offset-md-4"><button type="button" class="btn btn-primary btn-md ml-auto" onclick='saveGroupColumns()'><%= rb.getString("group")%></button>  </div>
    			</div>
    		  </div>
              <div class="form-row">
              	<div class="text-center" style="min-width: 500px;background-color: lightblue"><span><h3>Choose options from left to right.</h3></span></div> 
              </div>
              <div class="form-row">
                	<div class="pull-right"><button type="button" class="btn btn-success btn-md ml-auto" onclick='toggleColumnModal()'><%= rb.getString("submit")%></button>  </div>
                	<div class="pull-right"><button type="button" class="btn btn-danger btn-md ml-auto" onclick='clearWorkArea();toggleColumnModal()'><%= rb.getString("cancel")%></button> </div>
              </div>
              <div class="form-row">
              	<div style="min-width: 500px;min-height: 16px;background-color: lightblue"><span><h3></h3></span></div> 
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
    
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
			    	<div id=menus class="col-md-8 col-sm-12 col-xs-12v">
				      	<div id="level1" class="col-md-5 col-sm-5 col-xs-12v">
							<div class="col-4" id="level1Selection"></div>
				      	</div>
				      	
				      	<div id="level2" class="col-md-2 col-sm-6 col-xs-12v">
				    		<div class="col-2" id="level2Selection"></div>
					   	</div>
				      	    	
				      	<div id="level3" class="col-md-2 col-sm-6 col-xs-12v">
							<div class="col-2" id="level3Selection"></div>
				      	</div>
				
				      	<div id="level4" class="col-md-3 col-sm-6 col-xs-12v">
							<div class="col-2" id="level4Selection"></div>
				      	</div>
			      	</div>
				      	<div id="level5" class="col-md-3 col-sm-6 col-xs-12v">
							<div class="col-2" id="level5Selection"></div>
				      	</div>
		      	</div>	
			
				<div class="col-md-12">
			    </div>
		    </div>
			<div id="btnrow" class="row">
	    		<div class="col-sm-4">
	        		<button id="clearBtn"type="button" class="btn btn-danger btn-md ml-1 " onclick='clearProblemArea()'><%= rb.getString("clear")%></button>
	        		<button id="visualizerBtn" type="button" class="offset-1 col-2 btn btn-primary btn-md ml-1 " onclick='setWideScreen(0);setupTrialVisualizer()'><%= rb.getString("visualize")%></button>
	        		<button id="wideViewBtn"type="button" class="offset-1 col-2 btn btn-primary btn-md ml-1 " onclick='setWideScreen(1);setupTrialVisualizer()'><%= rb.getString("wide_view")%></button>
	    		</div>
	    		<div class="col-sm-4">
	      			<h3></h3>
	    		</div>
	  		</div>
		    <div class="row">
		    	<div id="rptHeaders" class="container-fluid">
					<div id="gridHeader" class="col-md-6" >
					</div>  	
					<div id="rptHeader2" class="col-md-6" >
					</div>  	
				</div>    
		    </div>
			<div id="metricsGrid" class="col-md-6" >
 			
			  <table class="table table-striped table-bordered measuresTable">
			    <thead>
			      <tr>
			        <th><%= rb.getString("measures")%></th>
			        <th><%= rb.getString("student")%></th></th>
			        <th><%= rb.getString("average")%></th></th>
			      </tr>
			    </thead>
			    <tbody>
			      <tr>
			        <td><%= rb.getString("num_steps")%></td>
			        <td id="num_steps"></td>
			        <td></td>
			      </tr>
			      <tr>
			        <td><%= rb.getString("num_gobacks")%></td>
			        <td id="num_gobacks"></td>
			        <td></td>
			      </tr>
			      <tr>
			        <td><%= rb.getString("first_efficiency")%></td>
			        <td id="first_efficiency"></td>
			        <td></td>
			      </tr>
			      <tr>
			        <td><%= rb.getString("num_reset")%></td>
			        <td id="num_reset"></td>
			        <td></td>
			      </tr>
			      <tr>
			        <td><%= rb.getString("keypad_error")%></td>
			        <td id="keypad_error"></td>
			        <td></td>
			      </tr>
			      <tr>
			        <td><%= rb.getString("shaking_error")%></td>
			        <td id="shaking_error"></td>
			        <td></td>
			      </tr>
			      <tr>
			        <td><%= rb.getString("snapping_error")%></td>
			        <td id="snapping_error"></td>
			        <td></td>
			      </tr>
			      <tr>
			        <td><%= rb.getString("time_interaction")%></td>
			        <td id="time_interaction"></td>
			        <td></td>
			      </tr>
			      <tr>
			        <td><%= rb.getString("time_interaction_last_percent")%></td>
			        <td id="time_interaction_last_percent"></td>
			        <td></td>
			      </tr>
			      <tr>
			        <td><%= rb.getString("use_hint")%></td>
			        <td id="use_hint"></td>
			        <td></td>
			      </tr>
			    </tbody>
			  </table>
             <span class="tooltiptext">Metrics for selected student</span></a>                
			</div>		
			<div class="col-md-6" >
			</div>  	
	    </div>
		<div id="right-panel" class="col-md-4 col-sm-12 col-xs-12v">       
		   	<div id="visHeaderRow" class="row">
				<div class="col-md-5 visheader">
					<p><%= rb.getString("start_state")%></p>
				</div>		
				<div class="col-md-4 visheader">
					<p><%= rb.getString("goal_state")%></p>
				</div>		
				<div class="col-md-3 visheader">
					<p><%= rb.getString("best_steps")%></p>
				</div>		
			</div>
		   	<div id="visContentRow" class="row">
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
<script>

$(document).ready(function () {
    $("#columnCancelButton").click(function () {
      $('#columnsModal').modal('toggle')
    });
  });
  
  
</script>

</body>

</html>