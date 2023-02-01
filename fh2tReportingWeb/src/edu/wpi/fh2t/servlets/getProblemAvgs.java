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

public class getProblemAvgs extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public getProblemAvgs() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		PrintWriter out = response.getWriter();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");

		logger.setLevel(Level.DEBUG);
		
		logger.debug("getProblemAvgs servlet starting");			

		String averagesCollectionName = (String) session.getAttribute("expAverages");
		logger.debug("averages collection  = " + averagesCollectionName);		
		
		// Warning: if you add elements to metric[] you must add them to avgs[]  

		String metrics[] = { 
		"Number of Students Completed~students_completed~The total number of students in the study that have completed this problem",
		"Completion (1 = Yes / 0 = No)~completed~The proportion of students who completed the problem by successfully reaching the goal state at least once",  
		"Number of steps~num_steps~The number of steps that the students took for ALL attempts (both completions and non-completions)",
		"Number of go-backs~num_gobacks~The number of re-attempts in addition to the initial completion (after successfully reaching the goal state)",
		"Number of resets~num_reset~The number of times that students used the reset button to return the problem to the start state for ALL attempts (both completions and non-completions)",
		"Step-efficiency_first~first_efficiency~Ranging between 1 (perfect efficiency) to 0 (worst possible efficiency) for the students' first attempt at reaching the goal state",
		"Step-efficiency_last~last_efficiency~Ranging between 1 (perfect efficiency) to 0 (worst possible efficiency) for the students' final attempt at reaching the goal state",
		"Time taken (sec)~time_interaction~The total amount of time (in seconds) that the problem appeared on the screen",
		"Pause time - first (%)~time_interaction_first_percent~The proportion of the total time spent on the problem that was spent after opening the problem but before making the first step on the student's first attempt at reaching the goal state (pause time / total time)",
		"Pause time - last (%)~time_interaction_last_percent~The proportion of the total time spent on the problem that was spent after opening the problem but before making the first step on the student's final attempt at reaching the goal state (pause time / total time)",
		"Use of hints (1 = Yes / 0 = No)~use_hint~The proportion of students who requested a hint on this problem",
		"Number of total errors~total_error~The total number of errors that students made",
		"Number of keypad errors~keypad_error~The number of errors that students made by attempting to enter an non-equivalent expression using the keypad",
		"Number of shaking errors~shaking_error~The number of errors that students made by attempting to incorrectly use existing operators",
		"Number of snapping errors~snapping_error~The number of errors that students made by attempting to incorrectly reorder terms"
		};
		 

		
		
		// Warning: if you add elements to metric[] you must add them to avgs[]  
		String avgs[] = { "","","","","","","","","","","","","","",""};
		  
		String hdr = rb.getString("measures") + "~&nbsp;~ Average values for all students in the study who have completed the selected problem";
		
		String problemId = "";
		if (request.getParameter("problemId") != null) {
			problemId = request.getParameter("problemId");			
		}
		String problemPrefix = "p" + problemId + "_";
		logger.debug("problemPrefix=" + problemPrefix);
		
		MongoClient mongoClient = null;
		String servername = (String) request.getServerName();
		logger.debug("servername=" + servername);
		if (servername.startsWith("ssps")) {
			mongoClient = new MongoClient("localhost", 7010);
		}
		else {
			mongoClient = new MongoClient("0.0.0.0", 7010);
		}		logger.debug("MongoClient created");
		MongoDatabase experimentDB = mongoClient.getDatabase("gm-logs");
		logger.debug("User database=" + experimentDB.getName());


		MongoCollection<Document> avgCollection = (MongoCollection <Document>) experimentDB.getCollection(averagesCollectionName);
		
		boolean needsComma = false;
		String str = "{";
		int count = metrics.length;
		String avgLookup = "";
		for (int i = 0; i < count; i++) {		
			BasicDBObject avgQuery = new BasicDBObject();			
			String theMetric[] = metrics[i].split("~");
			avgLookup = problemPrefix + theMetric[1];
			avgQuery.put("field", avgLookup);
			
		    FindIterable<Document> avgIterable = (FindIterable<Document>) avgCollection.find(avgQuery);
		    Iterator<Document> iterator = avgIterable.iterator();
		    if (iterator.hasNext()) {
		        Document avgMetric = (Document) iterator.next();
		        avgs[i] = (String) avgMetric.get("values");
		        if (needsComma) { 
		        	str += ", "; 
		        }
		        else { 
		        	needsComma = true; 
		        }
				str += "\"" + metrics[i] + "\":\"" + "unused" + "~" + avgs[i] + "\"";
		    }else if(i == 0) {
		    	str += "\"Students\":\"0\"";
		    	break;
		    }
		    if (i == 0) {
	        	str += ", "; 
				str += "\"" + "&nbsp;" + "\":\"" + "unused" + "~" + "&nbsp;" + "\"";		    	
	        	str += ", "; 
				str += "\"" + hdr + "\":\"" + "unused" + "~" + rb.getString("overall_average") + "\"";		    	
		    }
		}
	    str += "}";
		mongoClient.close();
		out.print(str);
		logger.debug(str);
		logger.debug("end getProblemAvgs()");
				
	}
}
