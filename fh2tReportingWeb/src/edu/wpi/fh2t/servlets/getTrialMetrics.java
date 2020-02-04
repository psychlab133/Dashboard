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

import com.mysql.jdbc.Connection;
import com.mysql.jdbc.Statement;
import com.mysql.jdbc.PreparedStatement;

import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.MongoIterable;
import com.mongodb.BasicDBObject;
import com.mongodb.MongoClient; 
import com.mongodb.MongoCredential;

import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.Iterator;
import java.util.ResourceBundle;

import edu.wpi.fh2t.db.Student;

public class getTrialMetrics extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public getTrialMetrics() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		PrintWriter out = response.getWriter();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");

		logger.setLevel(Level.DEBUG);
		
		logger.debug("getTrials servlet starting");			

		String experimentID = "";
		if (request.getParameter("experimentID") != null) {
			experimentID = request.getParameter("experimentID");
		}

		String metricNames[] = { 
				"num_steps",
				"num_gobacks",
				"num_reset",
				"keypad_error",
				"keypad_error",
				"shaking_error",
				"snapping_error",
				"first_efficiency",
				"use_hint",
				"time_interaction",
				"time_interaction_last_percent"
		};
		
		String studentId = "";
		if (request.getParameter("studentId") != null) {
			studentId = request.getParameter("studentId");			
		}
		
		String problemId = "";
		if (request.getParameter("problemId") != null) {
			problemId = request.getParameter("problemId");			
		}
		String problemPrefix = "p" + problemId + "_";
		logger.debug("problemPrefix=" + problemPrefix);
		experimentID = "";
		
		Student student = new Student(studentId);
		
		logger.debug("getTrialMetrics servlet starting");			
		
		String query = "select studentID as SID, username, currentClass as Class from usernames WHERE studentID = '" + student.getName() + "' and not currentClass = '';";		
		logger.debug("query=" + query);
		Connection con = null;
		try {
			Class.forName((String) getServletContext().getInitParameter("dbClass"));
			con = (Connection) DriverManager.getConnection ((String) getServletContext().getInitParameter("iesdbUrl"),(String) getServletContext().getInitParameter("iesdbUser"),(String) getServletContext().getInitParameter("iesdbPwd"));
			PreparedStatement pstmt = (PreparedStatement)con.prepareStatement(query);
			ResultSet rs = pstmt.executeQuery(query);
			if (rs.next()) {
				logger.debug("getTrials for " + rs.getString("username"));			

				student.setId(rs.getString("username"));
			}
			rs.close();
		    pstmt.close();
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
	
/* replacement code using gm-logs database
		MongoClient mongoClient = new MongoClient("localhost", 7010);
		logger.debug("MongoClient created");
		MongoDatabase gmDB = mongoClient.getDatabase((String) getServletContext().getInitParameter("gm-DBName"));
		logger.debug("User database=" + gmDB.getName());
		MongoCollection<Document> collection = (MongoCollection <Document>) gmDB.getCollection((String) getServletContext().getInitParameter("gm-trials"));
*/
		
		MongoIterable<String> temp;
		MongoClient mongoClient = new MongoClient("localhost", 7010);
		logger.debug("MongoClient created");
		MongoDatabase experimentDB = mongoClient.getDatabase("gm-logs");
		logger.debug("User database=" + experimentDB.getName());
		temp = experimentDB.listCollectionNames();
		logger.debug("First experimentDB collection=" + temp.first());
	
		MongoCollection<Document> collection = (MongoCollection <Document>) experimentDB.getCollection("wpi_ies_study_fall_19_aggregation_table");
	
		logger.debug("search for " + student.getId());
		BasicDBObject searchQuery = new BasicDBObject();
		searchQuery.put("studentID", student.getId());
		
		int count = 0;
		
		String str = "{";
		
		boolean needsComma = false;
	    FindIterable<Document> findIterable = (FindIterable<Document>) collection.find(searchQuery);
	    Iterator<Document> iterator = findIterable.iterator();
	    while(iterator.hasNext()) {
	        Document metric = (Document) iterator.next();
	    	for (int n= 0; n < metricNames.length; n++) {
		        if (needsComma) { 
		        	str += ", "; }
		        else { 
		        	needsComma = true; 
		        }
	    		String metricValue = (String) metric.get(problemPrefix + metricNames[n]);
				str += "\"" + metricNames[n] + "\":\"" + metricValue + "\"";
	    	}
	    }
	    str += "}";
		mongoClient.close();
		out.print(str);
		logger.debug(str);
		logger.debug("end getTrialId()");
				
	}
}
