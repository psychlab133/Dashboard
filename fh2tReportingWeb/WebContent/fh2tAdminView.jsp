<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>

<%@ page import="javax.servlet.http.HttpSession"%>
<%@ page import="java.util.ResourceBundle"%>

<%@ page import="org.apache.log4j.Logger"%>
<%@ page import="org.apache.log4j.Level"%>

<% 
session = request.getSession();
ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");
Logger logger = (Logger) session.getAttribute("logger");
//logger.setLevel(Level.INFO);
logger.setLevel(Level.DEBUG);
logger.debug("WTF" + rb.getString("title"));
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

  var currentUser = "";
  
function getDashboardUsers() {

      var xmlhttp;
      if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
        xmlhttp = new XMLHttpRequest();
      }
      else {// code for IE6, IE5
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
      }
      xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
          var result = xmlhttp.responseText;
		  //alert(result);
          if (result.indexOf("Error") > -1) {
			  alert(result);
          }
          else {
        	  document.getElementById("UsersSelections").innerHTML = result;
          }
        }
      };
      
      var cmd = "GetDashboardUsers?filter=" + "none";
      //alert(cmd);
      xmlhttp.open("GET", cmd, true);
      xmlhttp.send();
	  
  }


function approveUser() {

    var xmlhttp;
    
    //alert("approveUser()");
    if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
      xmlhttp = new XMLHttpRequest();
    }
    else {// code for IE6, IE5
      xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }
    xmlhttp.onreadystatechange = function () {
      if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
        var result = xmlhttp.responseText;
		  //alert(result);
        if (result.indexOf("Error") > -1) {
			  alert(result);
        }
        else {
      	  document.getElementById("UsersSelections").innerHTML = result;
        }
      }
    };
    
    var strRoles = "";
    
    if ( document.getElementById("researcherRole").checked) {
    	strRoles +=  document.getElementById("researcherRole").value + "~";
    }
    if ( document.getElementById("teacherRole").checked) {
    	strRoles +=  document.getElementById("teacherRole").value + "~";
    }
    if ( document.getElementById("adminRole").checked) {
    	strRoles +=  document.getElementById("adminRole").value + "~";
    }
    if ( document.getElementById("developerRole").checked) {
    	strRoles +=  document.getElementById("developerRole").value + "~";
    }
    strRoles += "end";
    
    var cmd = "ApproveUser?username=" + currentUser + "&strRoles=" + strRoles;
    
    alert(cmd);
    xmlhttp.open("GET", cmd, true);
    xmlhttp.send();
	  
}


function toggleRolesModal() {
    	$('#rolesModal').modal('toggle');
  	}
  	
    function editUser() {
    	currentUser = "" + document.getElementById("usersSelections").value;
    	document.getElementById("rolesHeader").innerHTML = currentUser;
    	$("#right-panel").show();

      }

    function editUserCancel() {
    	currentUser = "";
    	$("#right-panel").hide();
    }
    
    $(document).ready(function () {
    	$("#right-panel").hide();
    
    });
    
    </script>

</head>

<body>
    <nav id="header-nav" class="navbar navbar-default">
      <div class="container">
        <div class="navbar-header">
            <a href="https://sites.google.com/view/from-here-to-there"  target="_blank" class="pull-left visible-md visible-lg">
              <div id="logon-img"></div>
            </a>

          <div class="navbar-brand">
            <a href="index.jsp">
              <h4><%= rb.getString("admin")%> <%= rb.getString("dashboard")%></h4>
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
          <ul id="nav-list" class="nav navbar-nav navbar-right">
            <li >
              <a id="Button" onclick="getDashboardUsers();">
                <span class="glyphicon glyphicon-user" id="UserMaintButton"></span><br class="hidden-xs"><%= rb.getString("users")%></a>
            </li>
            <li >
              <a id="Button" href='/index.jsp'>
                <span class="glyphicon glyphicon-log-out" id="SignOutButton"></span><br class="hidden-xs"><%= rb.getString("sign_out")%></a>
            </li>
          </ul><!-- #nav-list -->
        </div><!-- .collapse .navbar-collapse -->
      </div><!-- .container -->
    </nav><!-- #header-nav -->

<div class="row">
	<div id="shared-work-area">
		<div id="left-panel" class="col-md-6 col-sm-12 col-xs-12v">	   
		   	<div class="row">
			    <div id="selectionPanel" class="container-fluid selectionPanel">
			    	<div id=menus class="col-md-12 col-sm-12 col-xs-12v">
				      	<div id="level1" class="col-md-3 col-sm-5 col-xs-12v">
							<div class="col-3" id="UsersSelections"></div>
				      	</div>
				   	</div>
		      	</div>	
			
				<div class="col-md-12">
			    </div>
		    </div>
			<div id="btnrow" class="row">
	    		<div class="col-sm-12">
	        		<button id="clearBtn"type="button" class="btn btn-danger btn-md ml-1 pull-left hidden"><%= rb.getString("clear")%></button>
	    		</div>
	    		<div class="col-sm-4">
	      			<h3></h3>
	    		</div>
	  		</div>
	  	</div>
   
		<div id="right-panel" class="col-md-6 col-sm-12 col-xs-12v container">	 
  	  		<div class="col-md-12">
  				<p id="bpad"> </p>
  			</div>
			<div class="row">
				<div id="roles-panel" class="col-md-6">
					<p id="rolesHeader" class="text-center">Assign role(s)</p>
					<form>  
						<div class='form-group'>
							<div class="form-check">
							<label class="form-check-label">
							    <input type="checkbox" class="form-check-input" id="researcherRole" value="1">Researcher
							  </label>
							</div>
							<div class="form-check">
							  <label class="form-check-label">
							    <input type="checkbox" class="form-check-input" id="teacherRole" value="2" disabled>Teacher
							  </label>
							</div>
							<div class="form-check">
							  <label class="form-check-label">
							    <input type="checkbox" class="form-check-input" id="adminRole" value="3">Admin
							  </label>
							</div>
							<div class="form-check">
							  <label class="form-check-label">
							    <input type="checkbox" class="form-check-input" id="developerRole" value="4" disabled>Developer
							  </label>
							</div>
						</div>
					</form>
				</div>
				<div class="col-md-6"></div>
			</div>
			<div class="row">
				<div class="col-md-2"></div>
            	<div class="col-md-4">
            		<button id="submitButton" type="button" class="btn btn-primary btn-sm ml-1 pull-left"  tabindex="4" onclick='approveUser()'><%= rb.getString("submit")%></button>
   	        		<button id="cancelButton" type="button" class="btn btn-danger btn-sm ml-1 pull-left"  tabindex="4" onclick='editUserCancel();'><%= rb.getString("cancel")%></button>
				</div>
			</div>
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
  
  
	<!-- Modal -->
	<div class="modal fade" id="rolesModal" tabindex="-1" role="dialog" >
	  <div class="modal-dialog modal-dialog-centered" role="content">
	    <div class="modal-content">
	      <div class="modal-header">
	        <h5 class="modal-title" id="editUserTitle"></h5>
	        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
	          <span aria-hidden="true">&times;</span>
	        </button>
	      </div>      
	      <div class="modal-body">
		  	<div id="userChoicesRow" class="row">
	  			<div class="col-md-4 pull-left"></div>
	  			<div class="col-md-5 border" style="border-width: thick; border: 10px solid white; display:none" id="userChoices">
					<form>  
						<div class='form-group'><label>" + rb.getString("roles") + "</label>
							<div class='custom-control custom-checkbox'>
							<input type='checkbox' class='custom-control-input' id='researcherRole' name='roleSelections'>Researcher
							<input type='checkbox' class='custom-control-input' id='teacherRole' name='roleSelections'>Teacher
							<input type='checkbox' class='custom-control-input' id='adminRole' name='roleSelections'>Admin
							<input type='checkbox' class='custom-control-input' id='developerRole' name='roleSelections'>Developer
						</div>
					</form>
				</div>	           
	  			<div class="col-md-3 pull-right"></div>
	  	  		<div class="col-md-12">
	  				<p id="bpad"> </p>
	  			</div>
	  		</div>
			</div>
		    <div class="modal-footer">
	            <button id="submitButton" type="button" class="btn btn-primary btn-sm ml-1 pull-left"  tabindex="4" onclick='getDashboardUsers()'><%= rb.getString("submit")%></button>
	            <button id="cancelButton" type="button" class="btn btn-danger btn-sm ml-1 pull-left"  tabindex="4" onclick='close();'><%= rb.getString("cancel")%></button>
	        </div>
			
	      </div>
	  </div>
	</div>

</body>

</html>