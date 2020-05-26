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
import org.bson.Document;

import com.mongodb.BasicDBObject;
import com.mongodb.MongoClient;
import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.MongoIterable;
import com.mysql.jdbc.Connection;
import com.mysql.jdbc.Statement;
import com.mysql.jdbc.PreparedStatement;

import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.Iterator;
import java.util.ResourceBundle;

public class getDashboardUsers extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public getDashboardUsers() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");

		logger.setLevel(Level.DEBUG);
		
		PrintWriter out = response.getWriter();

		String colorName = "wheat";

		String filter="";
		if (request.getParameter("filter") != null) {
			filter = request.getParameter("filter");
		}
		else {
			if (session.getAttribute("filter") != null) {
				filter = (String) session.getAttribute("filter");
			}
			else {
				filter = "";
			}
		}	
		
		logger.debug("getDashboardUsers servlet using filter: " + filter);			

		String str = "";

		out.print("<div class='row'><div class='col-4 selection-header'><h4>" + rb.getString("users") + "</h4></div></div><div class='row'><div class='col-4'>");	
		out.print("<div class='col-4'><select id='usersSelections' class='custom-select' size='1' onchange=editUser();>");

		String query = "select username as UNAME, role as ROLE from usernames order by role, username;";					

		logger.debug("query=" + query);
		Connection con = null;
		try {

			Class.forName((String) getServletContext().getInitParameter("dbClass"));
			con = (Connection) DriverManager.getConnection ((String) getServletContext().getInitParameter("rptdbUrl"),(String) getServletContext().getInitParameter("rptdbUser"),(String) getServletContext().getInitParameter("rptdbPwd"));
			PreparedStatement pstmt = (PreparedStatement)con.prepareStatement(query);
			ResultSet rs = pstmt.executeQuery(query);
			str = "<option style='background-color:white;' value='User'>" + rb.getString("select_user") + "</option>";
			while (rs.next()) {
					String name = rs.getString("UNAME");
					int role = rs.getInt("ROLE");
					if (role == 0) {
						name = "*" + name;
					}
			    	str += "<option style='background-color:" + colorName + ";' value='" + rs.getString("UNAME") + "'> " + name + "</option>";
		    }
			rs.close();
		    pstmt.close();
			str += "</select></div>";
			str += "</div></div>";

		} //end try
		catch (ClassNotFoundException e1) {
			logger.error(e1.getMessage());
			logger.error(e1.fillInStackTrace());
			str = "Error: " + e1.getMessage();
		}
		catch(java.sql.SQLException e2) {
			logger.error(e2.getMessage());
			logger.error(e2.fillInStackTrace());
			str = "Error: " + e2.getMessage();
		}
		catch(Exception e) {
			logger.error(e.getMessage());
			logger.error(e.fillInStackTrace());
			str = "Error: " + e.getMessage();
		}
		finally {
			try {
				con.close();
			}
			catch(java.sql.SQLException e) {
				logger.error(e.getMessage());
				logger.error(e.fillInStackTrace());
			}			
		}
		
		logger.debug("str=" + str);
		out.print(str);
	}
	
}
