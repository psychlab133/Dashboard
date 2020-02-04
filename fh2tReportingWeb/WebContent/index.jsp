<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="javax.servlet.RequestDispatcher"%>
<%@ page import="javax.servlet.Servlet"%>
<%@ page import="javax.servlet.ServletConfig"%>
<%@ page import="javax.servlet.ServletException"%>
<%@ page import="javax.servlet.http.HttpServlet"%>
<%@ page import="javax.servlet.http.HttpServletRequest"%>
<%@ page import="javax.servlet.http.HttpServletResponse"%>

<%@ page import="org.apache.log4j.Logger"%>
<%@ page import="org.apache.log4j.PropertyConfigurator"%>
<%@ page import="org.apache.log4j.Level"%>
<%
	RequestDispatcher dispatcher = request.getRequestDispatcher("/Startup");    
	dispatcher.forward(request, response);
	
 %>
 
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>ft2hReporting</title>
</head>
<body>

</body>
</html>