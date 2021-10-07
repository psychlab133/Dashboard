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
import com.mongodb.client.model.Projections;
import com.mysql.jdbc.Connection;
import com.mysql.jdbc.Statement;
import com.mysql.jdbc.PreparedStatement;

import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.stream.Collectors;

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

		//logger.setLevel(Level.DEBUG);
		
		PrintWriter out = response.getWriter();

		String colorName = "Gray";
		if (request.getParameter("tablecolor") != null) {
			colorName = request.getParameter("tablecolor");
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
		
		String problemId = "121";
		if (request.getParameter("problemId") != null) {
			problemId = request.getParameter("problemId");			
		}
		
		String sortBy = "";
		if (request.getParameter("sortBy") != null) {
			sortBy = request.getParameter("sortBy");
		}
		
		String sortOrder = "";
		if (request.getParameter("sortOrder") != null) {
			sortOrder = request.getParameter("sortOrder");
		}
		
		String collectionName = (String) session.getAttribute("expAggregation");
		logger.debug("collection  = " + collectionName);

		logger.debug("getStudents servlet using filter: " + filter);			

		String str = "";

		out.print("<div class='row'><div class='col-4 selection-header'><h4>" + rb.getString("students") + "</h4></div></div><div class='row'><div class='col-4'>");	
		out.print("<div class='col-4'><select id='usernamesSelections' class='custom-select' size='1' onchange=setStudent();>");

		String query = "";

//		String query = "select studentID as SID, username, currentClass as Class from usernames WHERE studentID like '" + filter + "' and not currentClass = '';";		
		if (filter.equals("FS%")) {
			logger.debug("unfiltered");
			query = "select studentID as SID, username as UNAME from usernames WHERE not currentClass = ''" + "order by studentID;";					
		}
		else {
			query = "select studentID as SID, username as UNAME from usernames WHERE studentID like '" + filter + "' and not currentClass = ''" + "order by studentID;";		
		}
		logger.debug("query=" + query);
		Connection con = null;
		List<String> studentIDList = new ArrayList<String>();
		List<String> userNameList = new ArrayList<String>();
		try {

			MongoClient mongoClient = new MongoClient("localhost", 7010);
			logger.debug("MongoClient created");
			MongoDatabase experimentDB = mongoClient.getDatabase("gm-logs");
			logger.debug("User database=" + experimentDB.getName());
			MongoCollection<Document> collection = (MongoCollection <Document>) experimentDB.getCollection(collectionName);	
			
			Class.forName((String) getServletContext().getInitParameter("dbClass"));
			con = (Connection) DriverManager.getConnection ((String) getServletContext().getInitParameter("iesdbUrl"),(String) getServletContext().getInitParameter("iesdbUser"),(String) getServletContext().getInitParameter("iesdbPwd"));
			PreparedStatement pstmt = (PreparedStatement)con.prepareStatement(query);
			ResultSet rs = pstmt.executeQuery(query);
			str = "<option style='background-color:white;' value=''>Select Student</option>";
			while (rs.next()) {
				studentIDList.add(rs.getString("SID"));
				userNameList.add(rs.getString("UNAME"));
			}
/*			while (rs.next()) {
				boolean studentCompletedProblem = false;
				if (problemId.length() == 0) {
					studentCompletedProblem = true;	
				}
				else {
					// See if this student completed this problem
					String username = rs.getString("UNAME");
					studentCompletedProblem = didStudentSolveProblem(problemId,username,collection);
				}
				if (studentCompletedProblem) {
					studentIDList.add(rs.getString("SID"));
					userNameList.add(rs.getString("UNAME"));
			    	str += "<option style='background-color:" + colorName + ";' value='" + rs.getString("SID") + "'> " + rs.getString("SID") + "</option>";
				}
				
		    }*/
				List<String> sortedStudentList = getSortedList(userNameList, logger, studentIDList, collection, problemId, sortOrder, sortBy);
				for (int i = 0; i < sortedStudentList.size(); i++) {
					str += "<option style='background-color:" + colorName + ";' value='" + sortedStudentList.get(i) + "'> " + sortedStudentList.get(i) + "</option>";
				}
//			}
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
	
	public List<String> getSortedList(List<String> userNameList, Logger logger, List<String> studentIDList, MongoCollection<Document> collection, String problemId, String sortOrder, String sortBy){
		
		String metrics[] = {
				"Number of steps",
				"Number of go-backs",
				"number of resets",
				"Step-efficiency first",
				"Step-efficiency last",
				"Time taken(sec)",
				"Pause time-first",
				"Pause time-last",
				"Number of total errors",
				"Number of keypad errors",
				"Number of shaking errros",
				"Number of snapping errors"
				};
			String sortMetrics[] = {
				"_num_steps",
				"_num_gobacks",
				"_num_reset",
				"_first_efficiency",
				"_last_efficiency",
				"_time_interaction",
				"_time_first",
				"_time_last",
				"_total_error",
				"_keypad_error",
				"_shaking_error",
				"_snapping_error"
			};
			
		List<BasicDBObject> sortQueryList = new ArrayList<BasicDBObject>();
	    BasicDBObject sortQuery = new BasicDBObject();	    
	    Map<String, String> sortedStudentList = new HashMap<String, String>();
	    List<String> sortedStudentIDList = new ArrayList<String>();
	    
//	    sortQuery.put("studentID", new BasicDBObject("$in", userNameList));
	    sortQueryList.add(new BasicDBObject("studentID", new BasicDBObject("$in", userNameList)));
		String problemPrefix = "p" + problemId;
		logger.debug("problemPrefix=" + problemPrefix);	    
		String sortField = "";
		
		if (sortBy != "" && sortOrder != "") {
			sortField = problemPrefix + sortMetrics[Arrays.asList(metrics).indexOf(sortBy)];;
//		    sortQuery.put(sortField, new BasicDBObject("$ne", "N/A"));
		    sortQueryList.add(new BasicDBObject(sortField, new BasicDBObject("$ne", "N/A")));			
		}

	    sortQueryList.add(new BasicDBObject(problemPrefix+"_completed", "1"));
	    sortQuery.put("$and", sortQueryList);

	    FindIterable<Document> findIterable = (FindIterable<Document>) collection.find(sortQuery).projection(Projections.include("studentID", sortField));//.sort(new BasicDBObject("s1_num_steps",1));
		Iterator<Document> iterator = findIterable.iterator();

		Document metric = null;
		String sortedStudent = "";
		String studentNum = "";
		while(iterator.hasNext()) {
			metric = (Document) iterator.next();
			sortedStudent = (String) metric.get("studentID");
			if (sortBy != "" && sortOrder != "") {
				studentNum = (String) metric.get(sortField);				
				sortedStudentList.put(studentIDList.get(userNameList.indexOf(sortedStudent)), studentNum);
				}
			else {
				sortedStudentIDList.add(studentIDList.get(userNameList.indexOf(sortedStudent)));
			}
		}
		if (sortBy != "" && sortOrder != "") {
			sortedStudentIDList = sortedStudentList.entrySet()
					.stream()
					.sorted((i1, i2)
								-> sortOrder.equals("Ascending") ? (i1.getValue().compareTo(
									i2.getValue()) == 0 ? i1.getKey().compareTo(
									i2.getKey()) : i1.getValue().compareTo(
									i2.getValue())) : (i2.getValue().compareTo(
											i1.getValue()) == 0 ? i1.getKey().compareTo(
													i2.getKey()) : i2.getValue().compareTo(
													i1.getValue())) ).map(Map.Entry::getKey)
					.collect(Collectors.toList());
		}else {
			Collections.sort(sortedStudentIDList);
		}
		
		return sortedStudentIDList;
	}
	
	public boolean didStudentSolveProblem(String problemId, String username, MongoCollection<Document> collection) {
		boolean result = false;
		// See if this student completed this problem
		String problemPrefix = "p" + problemId + "_";
		//logger.debug("problemPrefix=" + problemPrefix);


		BasicDBObject completedQuery = new BasicDBObject();
		completedQuery.put("studentID", username);

		FindIterable<Document> findIterable = (FindIterable<Document>) collection.find(completedQuery);
		Iterator<Document> iterator = findIterable.iterator();
		while(iterator.hasNext()) {
			Document metric = (Document) iterator.next();
			String completedValue = (String) metric.get(problemPrefix + "completed");
			if (completedValue.equals("1")) {
				result = true;
			}
		}

		return result;
		
	}

}
