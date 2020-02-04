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

public class getStudents extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public getStudents() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");

		logger.setLevel(Level.DEBUG);
		
		PrintWriter out = response.getWriter();

		String colorName = "Gray";
		if (request.getParameter("tablecolor") != null) {
			colorName = request.getParameter("tablecolor");
		}

		String level="";
		if (request.getParameter("level") != null) {
			level = request.getParameter("level");
		}

		String filter="";
		if (request.getParameter("filter") != null) {
			filter = request.getParameter("filter");
		}
		else {
			if (session.getAttribute("filter") != null) {
				filter = (String) session.getAttribute("filter");
			}
			else {
				filter = "FS";
			}
		}	
		filter += "%";

		logger.debug("getStudents servlet using filter: " + filter);			

		String str = "";

//		str = "<div class='row'><div class='col-4'><h4>" + rb.getString("students") + "</h4></div></div><div class='row'><div class='col-2'><h4></h4></div><div class='col-8'><button type='button' class='btn btn-danger btn-sm ml-1 ' onclick='resetStudents()'>" + rb.getString("reset") + "</div><div class='col-2'><h4></h4></div></div><div class='row'><div class='col-4'>";	
		str = "<div class='row'><div class='col-4 selection-header'><h4>" + rb.getString("students") + "</h4></div></div><div class='row'><div class='col-4'>";	
		out.print(str);
		out.print("<div class='col-4'><select id='usernamesSelections' class='custom-select' size='8' onchange=setStudent();>");

		str = "";
		String query = "";

//		String query = "select studentID as SID, username, currentClass as Class from usernames WHERE studentID like '" + filter + "' and not currentClass = '';";		
		if (filter.equals("FS")) {
			query = "select studentID as SID, username from usernames WHERE not currentClass = ''" + "order by studentID;";					
		}
		else {
			query = "select studentID as SID, username from usernames WHERE studentID like '" + filter + "' and not currentClass = ''" + "order by studentID;";		
		}
		logger.debug("query=" + query);
		Connection con = null;
		try {
			MongoClient mongoClient = new MongoClient("localhost", 7010);
			logger.debug("MongoClient created");
			MongoDatabase gmDB = mongoClient.getDatabase((String) getServletContext().getInitParameter("gm-DBName"));
			logger.debug("User database=" + gmDB.getName());
			MongoCollection<Document> collection = (MongoCollection <Document>) gmDB.getCollection((String) getServletContext().getInitParameter("gm-trials"));
			
			Class.forName((String) getServletContext().getInitParameter("dbClass"));
			con = (Connection) DriverManager.getConnection ((String) getServletContext().getInitParameter("iesdbUrl"),(String) getServletContext().getInitParameter("iesdbUser"),(String) getServletContext().getInitParameter("iesdbPwd"));
			PreparedStatement pstmt = (PreparedStatement)con.prepareStatement(query);
			ResultSet rs = pstmt.executeQuery(query);
			while (rs.next()) {
				//logger.debug("username = " + rs.getString("username"));
				BasicDBObject searchQuery = new BasicDBObject();
				searchQuery.put("assistments_user_id", rs.getString("username")); 			
			    FindIterable<Document> findIterable = (FindIterable<Document>) collection.find(searchQuery).limit(1);
			    Iterator<Document> iterator = findIterable.iterator();
			    if (iterator.hasNext()) {
			    	str += "<option style='background-color:" + colorName + ";' value='" + rs.getString("SID") + "'> " + rs.getString("SID") + "</option>";
			    }
//			    else {
//			    	logger.debug("No Trial found of " + rs.getString("username"));
//			    }
		    }
			rs.close();
		    pstmt.close();
			mongoClient.close();

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
		out.print("</select></div>");
		out.print("</div></div>");
	}
}
