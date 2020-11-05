<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>

<%@ page import="javax.servlet.http.HttpSession"%>
<%@ page import="java.util.ResourceBundle"%>

<%@ page import="org.apache.log4j.Logger"%>
<%@ page import="org.apache.log4j.Level"%>

<%@ page import="edu.wpi.fh2t.utils.*"%>

<% 
session = request.getSession();
ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");
Logger logger = (Logger) session.getAttribute("logger");
//logger.setLevel(Level.INFO);
logger.setLevel(Level.DEBUG);
logger.debug("WTF" + rb.getString("title"));

Person currentUser = (Person) session.getAttribute("currentUser");
currentUser.setCurrentRole("Researcher");
currentUser.getName();

String ExperimentID  = "Fall 2019- GA Study FC";
String ExperimentAbbr = "";


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
  	function ResearcherPageSelected(evt) {
   	  var a_href = $('#selectorContinueButton').attr('href');
   	  $('#selectorContinueButton').attr('href','/fh2tReportingWeb/fh2tResearcherView.jsp?expAddr=FS');
   	}
</script>

<script>
  var currentUser = "<%=currentUser.getName()%>";
  var expId = "<%=ExperimentID%>";
  var expAddr = "";
  var expId = "";
  var expDisplay = "";
  
  
function getExperiments() {
	var xmlhttp;
    if (window.XMLHttpRequest) { // code for IE7+, Firefox, Chrome, Opera, Safari
        xmlhttp = new XMLHttpRequest();
    }
    else { // code for IE6, IE5
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }
    xmlhttp.onreadystatechange = function () {
	    if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
	          
	          var rsp = xmlhttp.responseText;
	          //alert(rsp);
	          document.getElementById("experimentList").innerHTML = xmlhttp.responseText;           
	    }
    };
      
    var cmd = "GetExperiments";
    //alert(cmd);
    xmlhttp.open("GET", cmd, true);
    xmlhttp.send();
}



function saveExperimentInfo() {
    	         
	var xmlhttp;
    if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
        xmlhttp = new XMLHttpRequest();
    }
    else {// code for IE6, IE5
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
            //alert("ready");
            var rsp = xmlhttp.responseText;
            //alert(rsp);
        }
    };
    var cmd = "SaveExperimentInfo?expId=" + expId + "&expDisplay=" + expDisplay + "&expAbbr=" + expAbbr;
	//alert(cmd); 
	xmlhttp.open("GET", cmd, true);		
	xmlhttp.send();
}

function setExperiment() {
	var index = document.getElementById('experimentSelections').selectedIndex;
	expDisplay = document.getElementById('experimentSelections').options[index].text;
	var x = document.getElementById("experimentSelections").value;
	var temp = x.split("~");
	expAbbr = temp[0];
	expId = temp[1];
	saveExperimentInfo();
	$("#selectorContinueButton").show();

}

$(document).ready(function () {
	getExperiments();
	$("#selectorContinueButton").hide();
});
 

</script>

</head>

<body id="login-body">
    <nav id="header-nav" class="navbar navbar-default">
      <div class="container">
        <div class="navbar-header">
            <a href="https://sites.google.com/view/from-here-to-there" class="pull-left visible-md visible-lg">
              <div id="logon-img"></div>
            </a>

          <div class="navbar-brand">
              <h4><%= rb.getString("experiments")%></h4>
          </div>

          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#collapsable-nav">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
        </div>

        <div id="collapsable-nav" class="collapse navbar-collapse hidden">
          <ul id="nav-list" class="nav navbar-nav navbar-right">
            <li >
              <a>
                <span class=" glyphicon glyphicon-info-sign hidden"></span><br class="hidden-xs" ></a>
            </li>
          </ul><!-- #nav-list -->
        </div><!-- .collapse .navbar-collapse -->
      </div><!-- .container -->
    </nav><!-- #header-nav -->


  	<div id="ExperimentInfo" class="container-fluid login">
 	  	<div id="userChoicesRow" class="row">
	  		<div class="col-md-4 pull-left"></div>
	  		<div class="col-md-5 border" style="border-width: thick; border: 10px solid white;" id="userChoices">
		  		<div class="row">
  	  				<div class="col-md-2">
  						<p id="bpad"> </p>
  					</div>
		  	  		<div class="col-md-6">
						<h3><%=rb.getString("select_experiment")%></h3>
		  			</div>
  	  				<div class="col-md-4">
  						<p id="bpad"> </p>
  					</div>
		  		</div>
				<div class="row">
					<div id="selectorWindow">
	  	  				<div class="col-md-3">
	  						<p id="bpad"> </p>
	  					</div>
		      		  	<div class='col-md-6'>
							<div id="experimentList">
							</div>
		        	  	</div>
	  	  				<div class="col-md-3">
	  						<p id="bpad"> </p>
	  					</div>
					</div>
				</div>
		  		<div class="row">
		  	  		<div class="col-md-3">
		  				<p id="bpad"> </p>
		  			</div>
					<div class='col-sm-6'>
						<a id='selectorContinueButton' href='/fh2tReportingWeb/fh2tResearcherView.jsp' class='btn btn-primary btn-sm ml-1' role='button'><%=rb.getString("continue")%></a>
						<a id='selectorCancelButton' href='/fh2tReportingWeb/index.jsp' type='button' class='btn btn-danger btn-sm ml-auto'><%=rb.getString("cancel")%></a>
					</div>
					<div class="col-md-3">
		  				<p id="bpad"> </p>
		  			</div>		
		  		</div>
			</div>
	  		<div class="col-md-3 pull-right">
	  		</div>
	    </div>
  		<div class="row">
  	  		<div class="col-md-12">
  				<p id="bpad"> </p>
  			</div>
  		</div>
  </div>
  <div class="footer">
    <div class="container">
      <div class="row">
      	<div class="col-md-3"></div>
        <div class="col-xs-12 col-md-6">
          <p class="glyphicon glyphicon-copyright-mark copyright"><%= rb.getString("copyright")%></p>
        </div>
      	<div class="col-md-3"></div>
      </div>
    </div>
  </div>
</div>

  


</body>

</html>