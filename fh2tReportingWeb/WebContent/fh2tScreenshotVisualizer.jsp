
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
logger.setLevel(Level.DEBUG);
String ServerName = (String) request.getServerName();
//ServerName = "localhost";
logger.info("servername=" + ServerName);

Person currentUser = (Person) session.getAttribute("currentUser");
currentUser.setCurrentRole("Researcher");
String experimentAbbr = (String) session.getAttribute("expAbbr");
String experimentDisplay = (String) session.getAttribute("expDisplay");
String currentStudent = (String) session.getAttribute("currentStudent");
logger.debug("currentStudent=" + currentStudent);
String currentProblem = (String) session.getAttribute("currentProblem");
String best_step = (String) session.getAttribute("best_step");
String start_state = (String) session.getAttribute("start_state");
String goal_state = (String) session.getAttribute("goal_state");
String title = currentStudent + ": " + start_state;
logger.setLevel(Level.INFO);
%>
    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><%=title%></title>
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

	var currentStudent = "<%=currentStudent%>";
	var currentProblem = "<%=currentProblem%>";
	var start_state = "<%=start_state%>";
	var goal_state = "<%=goal_state%>";
	var best_step = "<%=best_step%>";
	
       
    $(document).ready(function () {
//  		var url = "http://" + serverName + ":9000/clustervis_condensed.php?username=" + currentUser;
//  	  	$('#fullPageViewBtn').attr('href',url);
//   		$('#fullPageViewBtn').click();
   	    	
	    $("#wide-work-area").hide();
 		iframeLine = "<iframe src='http://" + serverName + ":9000/clustervis_condensed.php?username=" + currentUser + "' width = '100%' height = '600' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>"
 		document.getElementById("wideView").innerHTML =	iframeLine;
 		$("#wide-work-area").show();
    	var title1 = "<h5>Student: " + currentStudent + "</h5>";
    	document.getElementById("ScreenshotPageStudent").innerHTML = title1;

 		var start_state_label = "<%= rb.getString("start_state")%>";
 		var goal_state_label = "<%= rb.getString("goal_state")%>";
 		var best_step_label = "<%= rb.getString("best_step")%>";
    	var title2 = "<h5>" + start_state_label + " : " + start_state + "      |      " + goal_state_label + " : " + goal_state + "      |      " + best_step_label + " : " + best_step + "</h5>";

    	
    	document.getElementById("ScreenshotPageTitle").innerHTML = title2;

      });

</script>

</head>
<body>
	<header>
    <div class="row">
    	<div id="ResearchPageHeader">
    		<div id="ScreenshotPageStudent" class="col-md-2 col-sm-12 col-xs-12v pull-left">	   	    	
    		</div>
    		<div id="ScreenshotPageTitle" class="col-md-8 col-sm-12 col-xs-12v pull-left">	   
    		</div>
    		<div id="ResearchPageSignoutButton"class="col-md-2 col-sm-12 col-xs-12v pull-right">
              	<a id="Button" href='/index.jsp'>
                	<class="hidden-xs pull-right"><%= rb.getString("sign_out")%></a>
    		</div>	
    	</div>
    </div> 
    </header>
    

<div class="row">
	<div id="shared-work-area container">
	</div>
	<div id="wide-work-area">
		<div class="row">
			<div class="col-md-1"></div>  	
		    <div id="wideView" class="col-md-11"></div>    
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