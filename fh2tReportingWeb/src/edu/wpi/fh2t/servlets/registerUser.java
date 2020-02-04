package edu.wpi.fh2t.servlets;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;

import com.mysql.jdbc.Connection;
import com.mysql.jdbc.Statement;
import com.mysql.jdbc.PreparedStatement;

import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.ResourceBundle;

import edu.wpi.fh2t.utils.*;

public class registerUser extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public registerUser() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,			
		HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");
		
		
		
		logger.setLevel(Level.DEBUG);

		PrintWriter out = response.getWriter();

		String username = "";
		if (request.getParameter("username") != null) {
			username = request.getParameter("username");
		}

		String pwd="";
		if (request.getParameter("pwd") != null) {
			pwd = request.getParameter("pwd");
		}
		
		String pwd2="";
		if (request.getParameter("pwd2") != null) {
			pwd2 = request.getParameter("pwd2");
		}

		String email="";
		if (request.getParameter("email") != null) {
			email = request.getParameter("email");
		}
		
		String DBpwd = "";
		int DBuserid = 0;
		int DBrole = 0;
		String strRoles = "";
		String DBemail = "";
	
		String str = "";

		String query = "select password as PWD, role as ROLE, email as EMAIL, ID from usernames where username = '" + username + "';";		
		logger.debug("query=" + query);
		Connection con = null;
		try {
			Class.forName((String) getServletContext().getInitParameter("rptdbClass"));
			con = (Connection) DriverManager.getConnection ((String) getServletContext().getInitParameter("rptdbUrl"),(String) getServletContext().getInitParameter("rptdbUser"),(String) getServletContext().getInitParameter("rptdbPwd"));
			PreparedStatement pstmt = (PreparedStatement)con.prepareStatement(query);
			ResultSet rs = pstmt.executeQuery(query);
			if (rs.next()) {
				logger.debug("Username is taken. Please choose another.");
				str = "<h3>Error! Username is taken. Please choose another.</h3>";
			}			
			rs.close();
		    pstmt.close();
		    String insertQuery = "INSERT into usernames (username,password,email,role) Values ('" + username + "', '" + pwd + "', '" + email + "', 3);";
		    logger.debug(insertQuery);
		    PreparedStatement insertPstmt = (PreparedStatement)con.prepareStatement(insertQuery);
			insertPstmt.execute(insertQuery);
			con.close();
		} //end try
		catch (ClassNotFoundException e1) {
			logger.error(e1.getMessage());
			logger.error(e1.fillInStackTrace());
		}
		catch(java.sql.SQLException e2) {
			logger.error(e2.getMessage());
			logger.error(e2.fillInStackTrace());
		}
		catch(Exception e) {
			logger.error(e.getMessage());
			logger.error(e.fillInStackTrace());
		}
		if (str.length() == 0) {
			if (!(pwd.trim().equals(pwd2.trim()))) {
				logger.debug("Passwords don't match: " + pwd.trim() + " " + pwd2.trim());
				str = "<h3>Error! Passwords don't match. Please try again.</h3>";
			}
			else {
				if (email.indexOf("@") == -1) {
					logger.debug("Error! Invalid email address. Please try again.");
					str = "<h3>Error! Invalid email address. Please try again.</h3>";
				}
				else {
					logger.debug("Add user to DB");
					str = username + " was added to DB. You are now welcome to log in.";
				}
			}
		}
		out.print(str);
	}
}
