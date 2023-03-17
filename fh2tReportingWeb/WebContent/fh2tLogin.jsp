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
	function TeacherPageSelected() {	
  	  var a_href = $('#selectorContinueButton').attr('href');
  	  $('#selectorContinueButton').attr('href','/fh2tTeacherView.jsp');
  	}
  	function ResearcherPageSelected() {
   	  var a_href = $('#selectorContinueButton').attr('href');
   	  $('#selectorContinueButton').attr('href','/fh2tExperiment.jsp');
   	}
  	function AdminPageSelected() {	
   	  var a_href = $('#selectorContinueButton').attr('href');
   	  $('#selectorContinueButton').attr('href','/fh2tAdminView.jsp');
   	}
    function DeveloperPageSelected() {
  	  var a_href = $('#selectorContinueButton').attr('href');
   	  $('#selectorContinueButton').attr('href','/fh2tDeveloperView.jsp');
  	}
  
  function loginRequest() {
      var username = document.getElementById("inputUsername");
      var txtUsername = username.value;
      var pwd = document.getElementById("inputPassword");
      var txtPwd = pwd.value;
     
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
          if (rsp.indexOf("Error") > -1) {

              document.getElementById("loginMsgRsp").innerHTML = xmlhttp.responseText;
          }
          else {
        	  var result = xmlhttp.responseText;
        	  //alert(result);
        	  if (result == "defaultPage") {
                  document.getElementById("selectorContinueButton").click();        		  
        	  }
        	  else {
        		  
	              document.getElementById("loginWindow").innerHTML = "";
	        	  $('#selectorContinueButton').show();
	        	  div = document.getElementById('userChoices')
	        	  div.style.display="block";
	              document.getElementById("userChoices").innerHTML = xmlhttp.responseText;
	              document.getElementById("userChoices").show();
	          }
          }
        }
      };
      
      if ((txtUsername.length > 0) && (txtPwd.length > 0 )) {	  

	      var cmd = "LoginRequest?username=" + txtUsername + "&pwd=" + txtPwd;
      	  //alert(cmd);
          xmlhttp.open("GET", cmd, true);
          xmlhttp.send();
      }
      else {
          document.getElementById("loginMsgRsp").innerHTML = "<%= rb.getString("all_fields_must_be_entered")%>";  
      }
    }    
  
  function sendPassword() {
	  //alert("sendPassword");
      var username = document.getElementById("inputUsername");
      var txtUsername = username.value;
     
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
          if (rsp.indexOf("Error") > -1) {

              document.getElementById("loginMsgRsp").innerHTML = xmlhttp.responseText;
        	  

          }
          else {
		        $('#confirmModal').modal('toggle');
        	 //var result = xmlhttp.responseText;
        	  //alert(result);
          }
        }
      };
      
      if (txtUsername.length > 0) {	  

	      var cmd = "SendPassword?username=" + txtUsername;
      	  //alert(cmd);
          xmlhttp.open("GET", cmd, true);
          xmlhttp.send();
      }
      else {
          document.getElementById("loginMsgRsp").innerHTML = "username must be entered";  
      }
    }       
       
       
      function registerUser() {
    	  
          var username = document.getElementById("signupUsername");
          var txtUsername = username.value;
          var pwd = document.getElementById("signupPassword");
          var txtPwd = pwd.value;
          var pwd2 = document.getElementById("signupPassword2");
          var txtPwd2 = pwd2.value;
          var email = document.getElementById("signupEmail");
          var txtEmail = email.value;
          
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
              if (rsp.indexOf("Error") > -1) {
                document.getElementById("signupMsgRsp").innerHTML = xmlhttp.responseText;
              }
              else {
                  $('#signupModal').modal('toggle');
            	  //alert(xmlhttp.responseText);
                  $('#loginModal').modal('toggle');
              }
            }
          };
      if ((txtUsername.length > 0) && (txtPwd.length > 0) && (txtPwd2.length > 0) && (txtEmail.length > 0 )) {	  
		  if (txtPwd === txtPwd2) {
	      		var cmd = "RegisterUser?username=" + txtUsername + "&pwd=" + txtPwd + "&pwd2=" + txtPwd2 + "&email=" + txtEmail;
	      		//alert(cmd);
	      		xmlhttp.open("GET", cmd, true);		
	      		xmlhttp.send();
		  }
		  else {
	          document.getElementById("signupMsgRsp").innerHTML = "<%= rb.getString("passwords_do_not_match")%>";  			  
		  }
      }
      else {
          document.getElementById("signupMsgRsp").innerHTML = "<%= rb.getString("all_fields_must_be_entered")%>";  
      }
    }    

  	function registerUserCancel() {

        document.getElementById("signupUsername").value = "";
        document.getElementById("signupPassword").value = "";
        document.getElementById("signupPassword2").value = "";
        document.getElementById("signupEmail").value = "";

		$('#signupModal').modal('toggle');
//    	$('#loginModal').modal('toggle');
	}

  	function toggleAboutModal() {
    	$('#aboutModal').modal('toggle');
  	}
    </script>

</head>

<body id="login-body">
    <nav id="header-nav" class="navbar navbar-default">
      <div class="container">
        <div class="navbar-header">
            <a href="https://sites.google.com/view/from-here-to-there"  target="_blank" class="pull-left visible-md visible-lg">
              <div id="logon-img"></div>
            </a>

          <div class="navbar-brand">
            <a href="index.jsp">
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
          <ul id="nav-list" class="nav navbar-nav navbar-right">
            <li >
              <a id="Button">
                <span class="glyphicon glyphicon-log-in hidden" id="loginButton"></span><br class="hidden-xs"></a>
            </li>
            <li >
              <a href="https://graspablemath.com/projects/fh2t"  target="_blank" id="Button">
                <span class="glyphicon glyphicon-play-circle" id="playButton"></span><br class="hidden-xs">Play</a>
            </li>
            <li>
              <a id="aboutButton" data-toggle="modal" data-target="#aboutModal">
                <span class="glyphicon glyphicon-info-sign glyphicon-info" id="aboutButton"></span><br class="hidden-xs"><%= rb.getString("about")%></a>
            </li>
            <li>
            <a id="manualDownload" href="pdf/Researcher_Dashboard_User_Manual.pdf" download="Researcher Dashboard User Manual">
                <span class="glyphicon glyphicon-download" id="manualDownload"></span><br class="hidden-xs"><%= rb.getString("user_manual")%></a>
            </li>
          </ul><!-- #nav-list -->
        </div><!-- .collapse .navbar-collapse -->
      </div><!-- .container -->
    </nav><!-- #header-nav -->


  <div id="loginInfo" class="container-fluid login">
	<div id="loginWindow">
		<div class="col-md-4"></div>
		<div id="loginForm" class="col-md-4 container">
            <form>
              <div class="form-row">          
                <div class="form-group">
                  <div class="form-group col-sm-12 center-text">
                     <div type=text id="loginMsgHdr" class="center-text login"><span><h3></h3></span></div>
                  </div>
                </div>
              
                <div class="form-group col-sm-12">
                  <input type="text" class="form-control form-control-sm mr-1" id="inputUsername"
                    placeholder="Enter username" tabindex="1">
                </div>
                <div class="form-group col-sm-12">
                  <input type="password" class="form-control form-control-sm mr-1" id="inputPassword"
                    placeholder="Password" tabindex="2">
                </div>
             </div>

              <div class="form-group">
                <div class="form-group col-sm-12 center-text">
                    <div type=text id="loginMsgRsp" class="center-text login"><span><h3></h3></span></div>
                </div>
              </div>       
              
              <div class="form-group">
                <button id="loginSubmitButton"  onclick="loginRequest();" type="button" class="btn btn-success btn-sm ml-1"  tabindex="3"><%= rb.getString("login")%></button>
                <button id="forgotPasswordButton" onclick="sendPassword();" type="button" class="btn btn-default btn-sm ml-1 pull-right"  tabindex="4" ><%= rb.getString("forgot_password")%></button>
                <button id="signupButton" type="button" class="btn btn-default btn-sm ml-1 pull-right"  tabindex="5" onclick='newUserEntry();'><%= rb.getString("sign_up")%></button>
              </div>       
            </form>
        </div>
		<div class="col-md-4"></div>

	</div>
  	<div id="userChoicesRow" class="row">
  		<div class="col-md-4 pull-left"></div>
  		<div class="col-md-5 border" style="border-width: thick; border: 10px solid white; display:none" id="userChoices"></div>
  		<div class="col-md-3 pull-right"></div>
  	  	<div class="col-md-12">
  			<p id="bpad"> </p>
  		</div>
  	</div>
            
	<div class='row'>
		<div class='col-md-5'></div>
		<div class='col-sm-2'>
			<a id='selectorContinueButton' href='/fh2tExperiment.jsp' class='btn btn-primary btn-sm ml-1' role='button'><%= rb.getString("continue")%></a>
		</div>
		<div class='col-md-5'></div>
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
<div class="modal fade" id="signupModal" tabindex="-1" role="dialog" >
  <div class="modal-dialog modal-dialog-centered" role="content">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLongTitle">Sign Up</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>      
      <div class="modal-body">
            <form>
              <div class="form-row">          
              
                <div class="form-group col-sm-12">
                  <input type="text" class="form-control form-control-sm mr-1" id="signupUsername"
                    placeholder="Enter username" tabindex="1" autofocus>
                </div>
                <div class="form-group col-sm-12">
                  <input type="text" class="form-control form-control-sm mr-1" id="signupPassword"
                    placeholder="Password" tabindex="2">
                </div>
                <div id="password2Entry" class="form-group col-sm-12">
                  <input type="text" class="form-control form-control-sm mr-1" id="signupPassword2"
                    placeholder="Re-Enter Password" tabindex="2">
                </div>
                <div id="emailEntry" class="form-group col-sm-12">
                  <input type="text" class="form-control form-control-sm mr-1" id="signupEmail"
                    placeholder="email address" tabindex="2">
                </div>
             </div>

              <div class="form-group">
                <div class="form-group col-sm-12 center-text">
                    <div type=text id="signupMsgRsp" class="center-text signup"><span><h3></h3></span></div>
                </div>
              </div>       
            </form>
		</div>
	    <div class="modal-footer">
            <button id="registerUserButton" type="button" class="btn btn-primary btn-sm ml-1 pull-left"  tabindex="4" onclick='registerUser()'><%= rb.getString("register_new_user")%></button>
            <button id="signupCancelButton" type="button" class="btn btn-danger btn-sm ml-1 pull-left"  tabindex="4" onclick='registerUserCancel()'><%= rb.getString("cancel")%></button>
        </div>
	 <div class="about-modal-body" style="font-size:10px">
		        <p>If you wish to request access to the FH2T researcher dashboard, you will need to submit a data-sharing agreement form. For more information about this process,
		         please email Erin Ottmar at erottmar@wpi.edu</p>  
				<!-- p><a href ="https://sites.google.com/view/from-here-to-there/participate?authuser=0" target="_blank">FH2T Access form</a></p-->
				<p>We will contact you as soon as we can</p>
	</div>
      </div>
  </div>
</div>

		<!-- Modal -->
		<div class="modal fade" id="aboutModal" tabindex="-1" role="dialog" >
		  <div class="modal-dialog modal-dialog-centered" role="content">
		      <!-- Modal content-->
		      <div class="modal-content">
		        <div class="modal-header">
		          <button type="button" class="close" data-dismiss="modal">&times;</button>
		          <h4 class="about-modal-header text-center">About Researcher Dashboard</h4>
		        </div>
		        <div class="about-modal-body"">
		          <p>If you wish to request access to the FH2T researcher dashboard, you will need to submit a data-sharing agreement form. For more information about this process, please fill out the google form below, or email Erin Ottmar at erottmar@wpi.edu.</p>  
<p>https://sites.google.com/view/from-here-to-there/participate?authuser=0</p>
<p>We will contact you as soon as we can.</p>
		        </div>
		        <div class="modal-footer about-version">
		          	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
		          	<p> </p>
		        	<div class="about-version text-center">
		          		<%= rb.getString("software_version")%>: <%= rb.getString("current_version")%>
		        	</div>
		        </div>
		      </div>
		  </div>
		</div>
		<div class="modal fade" id="confirmModal" tabindex="-1" role="dialog" >
		  <div class="modal-dialog modal-dialog-centered" role="content">
		      <div class="modal-content">
		        <div class="modal-header">
		          <h4 class="about-modal-header text-center">Researcher Dashboard</h4>
		        </div>
		        <div class="about-modal-body"">
		        <p></p>
		          <p>We have sent your password. Please check your email</p>
		          <p></p>
		        </div>
		        <div class="modal-footer about-version">
		        	<div class="about-version text-center">
		          		<%= rb.getString("software_version")%>: <%= rb.getString("current_version")%>
		        	</div>
		        </div>
		      </div>

		  </div>
		</div>
  <script>
    $(document).ready(function () {
//        $('#loginModal').modal('toggle');
		loginRequest();
        $('#selectorContinueButton').hide();
        $('#loginSubmitButton').show();
        $('#signupButton').show();
        $('#forgotPasswordButton').show();
        document.getElementById("loginMsgHdr").innerHTML = "<h3><%= rb.getString("signin_header")%></h3>";        
        document.getElementById("loginMsgRsp").innerHTML = "";        
        $('#inputUsername').focus();
    });

//    $(document).ready(function () {
        //to have your input focused every your modal open
//        $('#loginModal').on("shown.bs.modal", function() {
//            $('#inputUsername').focus();
//        });
//     });
    
    
    $(document).ready(function () {
        $('#password2Entry').hide();
        $('#emailEntry').hide();		
        $('#registerUserButton').hide();
      });

	function newUserEntry() {

        //$('#loginModal').modal('toggle');
        $('#signupModal').modal('toggle');
        $('#password2Entry').show();
        $('#emailEntry').show();
        $('#signupCancelButton').show();
        $('#registerUserButton').show();
             	
	}
        
    </script>

</body>

</html>