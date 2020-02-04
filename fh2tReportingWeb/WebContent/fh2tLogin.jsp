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
logger.setLevel(Level.INFO);
//logger.setLevel(Level.DEBUG);
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
	function TeacherPageSelected(evt) {	
  	  var a_href = $('#selectorContinueButton').attr('href');
  	  $('#selectorContinueButton').attr('href','/fh2tReportingWeb/fh2tTeacherView.jsp');
  	}
  	function ResearcherPageSelected(evt) {
   	  var a_href = $('#selectorContinueButton').attr('href');
   	  $('#selectorContinueButton').attr('href','/fh2tReportingWeb/fh2tResearcherView.jsp');
   	}
  	function AdminPageSelected(evt) {	
   	  var a_href = $('#selectorContinueButton').attr('href');
   	  $('#selectorContinueButton').attr('href','/fh2tReportingWeb/fh2tAdmnView.jsp');
   	}
    function DeveloperPageSelected(evt) {
  	  var a_href = $('#selectorContinueButton').attr('href');
   	  $('#selectorContinueButton').attr('href','/fh2tReportingWeb/fh2tDeveloperView.jsp');
  	}
  </script>


  <script>
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
              document.getElementById("userChoices").innerHTML = xmlhttp.responseText;
              $('#loginModal').modal('hide');
              document.getElementsById('loginContinueButton').focus();              
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
          document.getElementById("loginMsgRsp").innerHTML = "All fields must be entered";  
      }
    }       
      function registerUser() {
          var username = document.getElementById("inputUsername");
          var txtUsername = username.value;
          var pwd = document.getElementById("inputPassword");
          var txtPwd = pwd.value;
          var pwd2 = document.getElementById("inputPassword2");
          var txtPwd2 = pwd2.value;
          var email = document.getElementById("inputEmail");
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
                document.getElementById("loginMsgRsp").innerHTML = xmlhttp.responseText;
              }
              else {
			      document.getElementById("userChoices").innerHTML = xmlhttp.responseText;
                  $('#loginModal').modal('hide');
            	  alert(xmlhttp.responseText);
              }
            }
          };


      var cmd = "RegisterUser?username=" + txtUsername + "&pwd=" + txtPwd + "&pwd2=" + txtPwd2 + "&email=" + txtEmail;
      //alert(cmd);
      xmlhttp.open("GET", cmd, true);

      xmlhttp.send();
    }    

    
    </script>


</head>

<body id="login-body">
    <nav id="header-nav" class="navbar navbar-default">
      <div class="container">
        <div class="navbar-header">
            <a href="index.jsp" class="pull-left visible-md visible-lg">
              <div id="logon-img"></div>
            </a>


          <div class="navbar-brand">
            <a href="index.jsp">
              <h2><%= rb.getString("title")%></h2>
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
            <li onclick='toggleLoginModal()'>
              <a id="Button">
                <span class="glyphicon glyphicon-log-in" id="loginButton"></span><br class="hidden-xs"><%= rb.getString("sign_in")%></a>
            </li>
            <li onclick='getAbout()'>
              <a>
                <span class=" glyphicon glyphicon-info-sign"></span><br class="hidden-xs"><%= rb.getString("about")%></a>
            </li>
          </ul><!-- #nav-list -->
        </div><!-- .collapse .navbar-collapse -->
      </div><!-- .container -->
    </nav><!-- #header-nav -->


  <div id="loginInfo" class="container-fluid login">
  	<div id="userChoices">
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

    <div id="loginModal" class="modal fade" role="dialog">
      <div class="modal-dialog modal-md" role="content">
        <!-- Modal content-->
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title"><%= rb.getString("sign_in")%></h4>
            <button type="button" class="close btn-danger" data-dismiss="modal">&times;</button>
          </div>
          <div class="modal-body">
            <form>
              <div class="form-row">          
                <div class="form-group">
                  <div class="form-group col-sm-12 center-text">
                     <div type=text id="loginMsgHdr" class="center-text login"><span><h3></h3></span></div>
                  </div>
                </div>
              
                <div class="form-group col-sm-12">
                  <label class="login"><%= rb.getString("username")%>:</label>
                  <input type="text" class="form-control form-control-sm mr-1" id="inputUsername"
                    placeholder="Enter username" tabindex="1" autofocus>
                </div>
                <div class="form-group col-sm-12">
                  <label class="login"><%= rb.getString("password")%>:</label>
                  <input type="text" class="form-control form-control-sm mr-1" id="inputPassword"
                    placeholder="Password" tabindex="2">
                </div>
                <div id="password2Entry" class="form-group col-sm-12">
                  <label class="login"><%= rb.getString("confirm_password")%>:</label>
                  <input type="text" class="form-control form-control-sm mr-1" id="inputPassword2"
                    placeholder="Re-Enter Password" tabindex="2">
                </div>
                <div id="emailEntry" class="form-group col-sm-12">
                  <label class="login"><%= rb.getString("email_address")%>:</label>
                  <input type="text" class="form-control form-control-sm mr-1" id="inputEmail"
                    placeholder="email address" tabindex="2">
                </div>
             </div>

              <div class="form-group">
                <div class="form-group col-sm-12 center-text">
                    <div type=text id="loginMsgRsp" class="center-text login"><span><h3></h3></span></div>
                </div>
              </div>       
              
              <div class="form-group">
                <button id="loginCancelButton" type="button" class="btn btn-danger btn-sm ml-auto"  tabindex="5" onclick='toggleLoginModal()'><%= rb.getString("cancel")%></button>
                <button id="loginSubmitButton" type="button" class="btn btn-primary btn-sm ml-1"  tabindex="3" onclick='loginRequest()'><%= rb.getString("sign_in")%></button>
                <button id="addNewUserButton" type="button" class="btn btn-primary btn-sm ml-1"  tabindex="4" onclick='newUserEntry()'><%= rb.getString("add_new_user")%></button>
                <button id="registerUserButton" type="button" class="btn btn-primary btn-sm ml-1"  tabindex="4" onclick='registerUser()'><%= rb.getString("register_new_user")%></button>
            </form>
          </div>
        </div>
      </div>
    </div>
    
  
  <script>
    $(document).ready(function () {
      $("#loginButton").click(function () {
        $('#loginModal').modal('toggle')
        $('#loginContinueButton').hide();
        $('#loginSubmitButton').show();
        $('#addNewUserButton').show();
        $('#registerUserButton').hide();
        $('#password2Entry').hide();
        $('#emailEntry').hide();
        document.getElementById("loginMsgHdr").innerHTML = "<%= rb.getString("signin_header")%>";        
        document.getElementById("loginMsgRsp").innerHTML = "";        
        document.getElementsById('inputUsername').focus();
      });
    });
    $(document).ready(function () {
        $("#loginCancelButton").click(function () {
          $('#loginModal').modal('toggle')
        });
        //to have your input focused every your modal open
        $('#loginModal').on("shown.bs.modal", function() {
            $('#inputUsername').focus();
        });
     });

 
    
    $(document).ready(function () {
        $('#password2Entry').hide();
        $('#emailEntry').hide();		
        $('#registerUserButton').hide();
      });

	function newUserEntry() {

        $('#password2Entry').show();
        $('#emailEntry').show();
        $('#loginSubmitButton').hide();        
        $('#addNewUserButton').hide();
        $('#registerUserButton').show();
             	
	}
        
    </script>

</body>

</html>