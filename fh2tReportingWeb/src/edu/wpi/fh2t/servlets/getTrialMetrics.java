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
import com.mongodb.client.model.Projections;
import com.mongodb.BasicDBObject;
import com.mongodb.MongoClient; 
import com.mongodb.MongoCredential;

import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.ArrayList;
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

		//logger.setLevel(Level.DEBUG);
		
		logger.debug("getTrials servlet starting");			

		String metrics[] = { 
		"Completion (1 = Yes / 0 = No)~completed~Whether the student successfully reached the goal state at least once",  
		"Number of steps~num_steps~The number of steps that the student took for ALL attempts (both completions and non-completions)",
		"Number of go-backs~num_gobacks~The number of re-attempts the student has on this problem in addition to the initial completion (after successfully reaching the goal state)",
		"Number of resets~num_reset~The number of times that student used the reset button to return the problem to the start state for ALL attempts (both completions and non-completions)",
		"Step-efficiency_first~first_efficiency~Ranging between 1 (perfect efficiency) to 0 (worst possible efficiency) for the student's first attempt at reaching the goal state",
		"Step-efficiency_last~last_efficiency~Ranging between 1 (perfect efficiency) to 0 (worst possible efficiency) for the student's final attempt at reaching the goal state",
		"Time taken (sec)~time_interaction~The total amount of time (in seconds) that the problem appeared on the screen",
		"Pause time - first (%)~time_interaction_first_percent~The proportion of the total time spent on the problem that was spent after opening the problem but before making the first step on the student's first attempt at reaching the goal state (pause time / total time)",
		"Pause time - last (%)~time_interaction_last_percent~The proportion of the total time spent on the problem that was spent after opening the problem but before making the first step on the student's final attempt at reaching the goal state (pause time / total time)",
		"Use of hints (1 = Yes / 0 = No)~use_hint~Whether the student requested a hint on this problem",
		"Number of total errors~total_error~The total number of errors that student made",
		"Number of keypad errors~keypad_error~The number of errors that the student made by attempting to enter an non-equivalent expression using the keypad",
		"Number of shaking errors~shaking_error~The number of errors that the student made by attempting to incorrectly use existing operators",
		"Number of snapping errors~snapping_error~The number of errors that the student made by attempting to incorrectly reorder terms"
		};
		 
		  
		String avgs[] = { "","","","","","","","","","","","","",""};
		double totals[] = { 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0};
		
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
		
		Student student = new Student(studentId);

		String aggregationCollectionName = (String) session.getAttribute("expAggregation");
		logger.debug("aggregation collection  = " + aggregationCollectionName);
		
		
		logger.debug("getTrialMetrics servlet starting");			
		
		String query = "select StuID, username, ClaID as Class from dashboard_view WHERE StuID = '" + student.getName() + "' and not ClaID = '';";		
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
	
	
		MongoClient mongoClient = null;
		String servername = (String) request.getServerName();
		logger.debug("servername=" + servername);
		if (servername.startsWith("ssps")) {
			mongoClient = new MongoClient("localhost", 7010);
		}
		else {
			mongoClient = new MongoClient("0.0.0.0", 7010);
		}			

		logger.debug("MongoClient created");
		MongoDatabase experimentDB = mongoClient.getDatabase("gm-logs");
		logger.debug("User database=" + experimentDB.getName());
		//temp = experimentDB.listCollectionNames();
		//logger.debug("First experimentDB collection=" + temp.first());
	

		MongoCollection<Document> avgCollection = (MongoCollection <Document>) experimentDB.getCollection(aggregationCollectionName);
		ArrayList<String> projectionFields = new ArrayList<>();
		
		for (int i = 0; i < avgs.length; i++) {
			projectionFields.add(problemPrefix + metrics[i].split("~")[1]);
		}

		
	    FindIterable<Document> avgIterable = (FindIterable<Document>) avgCollection.find().projection(Projections.include(projectionFields.toArray(new String[0])));

	    Iterator<Document> iterator = avgIterable.iterator();
	    
	    
	    int totalStudents = 0;
	    while (iterator.hasNext()) {
	    	Document avgMetric = (Document) iterator.next();
	    	totalStudents++; // increment total number of students
	    	if (avgMetric.getString(problemPrefix+metrics[0].split("~")[1]).equals("1")) {
	    		totals[0]++; // update total number of students who completed
	    		totals[1]++;
	    	}
	    	for (int i = 2; i < avgs.length; i++) {
	    		String tempVal = avgMetric.getString(problemPrefix+metrics[i].split("~")[1]);
	    		tempVal = tempVal.equals("N/A")? "0.0" : tempVal;
	    		totals[i] += Double.parseDouble(tempVal);
	    	}
	    }

	    for (int i = 0; i < totals.length; i++) {
	    	if (i==0) {
	    		avgs[0] = Double.toString(totals[0]/totalStudents);
	    	} else {
		    	avgs[i] = Double.toString(totals[i]/totals[0]);
	    	}
	    }

		
		MongoCollection<Document> collection = (MongoCollection <Document>) experimentDB.getCollection(aggregationCollectionName);
		
		logger.debug("search for " + student.getId());
		BasicDBObject searchQuery = new BasicDBObject();
		searchQuery.put("studentID", student.getId());

		
		String str = "{";
		
		boolean needsComma = false;
	    FindIterable<Document> findIterable = (FindIterable<Document>) collection.find(searchQuery);
	    iterator = findIterable.iterator();
	    while(iterator.hasNext()) {
	        Document metric = (Document) iterator.next();
	    	for (int n= 0; n < metrics.length; n++) {
		        if (needsComma) { 
		        	str += ", "; }
		        else { 
		        	needsComma = true; 
		        }
		        String theMetric[] = metrics[n].split("~");
	    		String metricValue = (String) metric.get(problemPrefix + theMetric[1]);
				str += "\"" + metrics[n] + "\":\"" + metricValue + "~" + avgs[n] + "\"";
	    	}
	    }
	    str += "}";
		mongoClient.close();
		out.print(str);
		logger.debug(str);
		logger.debug("end getTrialId()");
				
	}
}
