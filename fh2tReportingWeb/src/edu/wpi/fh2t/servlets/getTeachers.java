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
import com.mysql.jdbc.Connection;
import com.mysql.jdbc.Statement;
import com.mysql.jdbc.PreparedStatement;

import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.Iterator;
import java.util.ResourceBundle;

public class getTeachers extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public getTeachers() {
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

		String filter = (String) session.getAttribute("expAbbr");
		
		if (request.getParameter("filter") != null) {
			filter = request.getParameter("filter");
		}
		filter += "%";
		
		String problemId = "1";
		if (request.getParameter("problemId") != null) {
			problemId = request.getParameter("problemId");			
		}

		String collectionName = (String) session.getAttribute("expAggregation");
		logger.debug("collection  = " + collectionName);
		
		logger.debug("getTeachers servlet using filter: " + filter);			

		String str = "";
		 
		str = "<div class='row'><div class='selection-header'><h4>" + rb.getString("teachers") + "</h4></div></div><div class='row'><div class='col-4'>";	
		out.print(str);
		out.print("<div><select id='teachersSelections' class='custom-select' size='0' min-width:90%; onchange=setTeacher();>");
		
		str = "<option style='background-color:white;' value='Teachers'>Select Teacher</option>";

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
		MongoCollection<Document> collection = (MongoCollection <Document>) experimentDB.getCollection(collectionName);

//		String query = "select studentID as SID, username, currentClass as Class from usernames WHERE studentID like '" + filter + "' and not currentClass = '';";		
		Connection con = null;
		try {
			
			Class.forName((String) getServletContext().getInitParameter("dbClass"));
			con = (Connection) DriverManager.getConnection ((String) getServletContext().getInitParameter("iesdbUrl"),(String) getServletContext().getInitParameter("iesdbUser"),(String) getServletContext().getInitParameter("iesdbPwd"));
			
			String query = "select distinct studentID, username as UNAME from usernames where studentID like '" + filter + "' and not currentClass = '' order by studentID";
			logger.debug("query=" + query);
			PreparedStatement pstmt = (PreparedStatement)con.prepareStatement(query);
//			pstmt.setString(1, filter);
			ResultSet rs = pstmt.executeQuery(query);
			boolean needsComma = false;
			String strTeacherIDs = "";
			String teacherID = "";
			while (rs.next()) {
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
					teacherID = ((String) rs.getString("studentID")).substring(0,6);
					//logger.debug("teacherID=" + teacherID);
					//logger.debug("teacherIDs=" + strTeacherIDs);
					if (strTeacherIDs.indexOf(teacherID) == -1) {
						str += "<option style='background-color:" + colorName + ";' value='" + teacherID + "'> " + teacherID + "</option>;";
						strTeacherIDs  += teacherID;
						if (needsComma) {
							strTeacherIDs  += ",";
						}
						else {
							needsComma = true;
						}
					}
					else {
					}
				}
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
		mongoClient.close();
		
		logger.debug("str=" + str);

		out.print(str);
		out.print("</select></div>");
		out.print("</div></div>");
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
