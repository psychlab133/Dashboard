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

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.Iterator;
import java.util.ResourceBundle;
import java.util.Date;

import edu.wpi.fh2t.db.Student;
import edu.wpi.fh2t.utils.Person;

public class getTrialEvents extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public getTrialEvents() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		PrintWriter out = response.getWriter();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");

		logger.setLevel(Level.DEBUG);
		
		logger.debug("getTrialEvents servlet starting");			

		String experimentID = "";
		if (request.getParameter("experimentID") != null) {
			experimentID = request.getParameter("experimentID");
		}
		
		String trialId = "";
		if (request.getParameter("trialId") != null) {
			trialId = request.getParameter("trialId");			
		}
		
		logger.debug("TrialId =" + trialId);
		experimentID = "";	

		//Person current = new Person(DBuserid,username,DBemail,strRoles);
		Person currentUser = (Person) session.getAttribute("currentUser");
		logger.debug("Current User is " + currentUser.getName());
		
		MongoClient mongoClient = new MongoClient("localhost", 7010);
		logger.debug("MongoClient created");
		MongoDatabase gmDB = mongoClient.getDatabase((String) getServletContext().getInitParameter("gm-DBName"));
		logger.debug("User database=" + gmDB.getName());

        String start_state = "";
        String goal_state = "";
        long trial_tstamp = 0;
        int trial_duration = 0;
        		
		BasicDBObject trialSearchQuery = new BasicDBObject();
		trialSearchQuery.put("id", trialId);
		MongoCollection<Document> trialCollection = (MongoCollection <Document>) gmDB.getCollection((String) getServletContext().getInitParameter("gm-trials"));

	    FindIterable<Document> trialIterable = (FindIterable<Document>) trialCollection.find(trialSearchQuery);
	    Iterator<Document> trialIterator = trialIterable.iterator();
	    while(trialIterator.hasNext()){
	        Document trial = (Document) trialIterator.next();
	        start_state = (String) trial.get("start_state");
	        goal_state = (String) trial.get("goal_state");
        	Date fmtTimestamp = (Date) trial.get("timestamp");
        	trial_tstamp = fmtTimestamp.getTime();
        	Object test_duration = trial.get("duration");
        	if (test_duration == null) {
        		logger.debug("duration is null");
        		trial_tstamp = 0;
        	}
        	else {
        		trial_duration = (int) trial.get("duration");
            	trial_tstamp = trial_tstamp - trial_duration;
        	}
	        logger.debug("start_state:" + start_state + " goal_state: " + goal_state + "duration" + Long.toString(trial_tstamp));
	        break;
	    }
		
		BasicDBObject eventSearchQuery = new BasicDBObject();
		eventSearchQuery.put("trial_id", trialId);
		MongoCollection<Document> dataCollection = (MongoCollection <Document>) gmDB.getCollection((String) getServletContext().getInitParameter("gm-data"));
		
		String str = "[";
		
		// event.csv file
		logger.debug("bw");
	    BufferedWriter bw = null;
	      try {
	    	  String filename = "C:/WPI/Visualizer/" + currentUser.getName() + "_events.csv";
	    	  File file = new File(filename);
	    	  if (!file.exists()) {
	    		  file.createNewFile();
	    			logger.debug("bw new file");
	    	  }

	    	  FileWriter fw = new FileWriter(file);
	    	  bw = new BufferedWriter(fw);
	  		logger.debug("bw writer");
		int count = 0;

		// CSV column headers
		String header = "expr_ascii,action,method,elapsed\n";
		bw.write(header);
		logger.debug("header=" + header);

		// Start State from Trial document
		//String seconds = "";
		//String remainder = "";
		String elapsed = "0.0";
		String startline = start_state + ", start," + goal_state + "," + elapsed + "\n";
		bw.write(startline);
		logger.debug("startline=" + startline);

		String line = "";
		//boolean first = true;
		boolean needsComma = false;
		
		long prevTime = trial_tstamp;
		//long duration = 0;
		//String timestamp = "{timestamp:1}";
		BasicDBObject eventSortQuery = new BasicDBObject();
		eventSortQuery.put("timestamp", 1);
		
	    FindIterable<Document> eventIterable = (FindIterable<Document>) dataCollection.find(eventSearchQuery).sort(eventSortQuery);
	    Iterator<Document> eventIterator = eventIterable.iterator();
	    while(eventIterator.hasNext()){
	        Document event = (Document) eventIterator.next();
        	Date fmtTimestamp = (Date) event.get("timestamp");
        	long tstamp = fmtTimestamp.getTime();
        	String subtype = (String) event.get("subtype");
        	
        	if (subtype.equals("math")) {
	        	String expr = (String) event.get("expr_ascii");
	        	String action = (String) event.get("action");
	        	action = action.replaceFirst("Action", "");
	        	if (action.equals("mistake")) {
		        	action = "error";
		        	String method = (String) event.get("method");
		        	if (method.equals("keypad")){
		        		elapsed = formatDuration(tstamp,prevTime);
		        		
		        		logger.debug("duration = " + elapsed);

			        	if (needsComma) { str += ", "; } else {	needsComma = true; }
			        	str += "{\"expr_ascii\":\"" + expr + "\", " + "\"action\":\"" + action + "\", " + "\"method\":\"" + "Keypad error" + "\"}";
			        	logger.debug(str);
			        	
			        	line = expr + "," + action + "," + "Keypad error" + "," + elapsed + "\n";
				        bw.write(line);		        		
		        	}
	        	}
	        	else {
	        		elapsed = formatDuration(tstamp,prevTime);
		        	logger.debug("duration = " + elapsed);

		        	if (needsComma) { str += ", "; } else {	needsComma = true; }
		        	str += "{\"expr_ascii\":\"" + expr + "\", " + "\"action\":\"" + action + "\", " + "\"method\":\"noop\" }";
		        	logger.debug(str);
		        	
		        	line = expr + "," + action + "," + "," + elapsed + "\n";
			        bw.write(line);
	        	}
        	}
        	if (subtype.equals("reset")) {	        	
        		elapsed = formatDuration(tstamp,prevTime);
	        	logger.debug("duration = " + elapsed);

	        	if (needsComma) { str += ", "; } else {	needsComma = true; }
	        	str += "{\"expr_ascii\":\"" + "reset" + "\", " + "\"action\":\"" + "reset" + "\", \"method\":\"noop\"}";
	        	logger.debug(str);

	        	line = "reset,reset,reset," + elapsed + "\n";
		        bw.write(line);
        	}
        	if (subtype.equals("mistake")) {	        	
	        	String action = "error";
	        	 
	        	String method = (String) event.get("method");
	        	if (method.equals("tap")) {
	        		method = "Shaking error";		     
	        	}
	        	else if (method.equals("drag")){
	        		method = "Snapping error";		     		        			
	        	}
	        	else if (method.equals("keypad")){
	        		method = "Keypad error";		     		        			
	        	}
	        	else {
	        		method = method + "error";
	        	}
        		elapsed = formatDuration(tstamp,prevTime);
	        	logger.debug("duration = " + elapsed);

	        	if (needsComma) { str += ", "; } else {	needsComma = true; }
	        	str += "{\"expr_ascii\":\""  + "noop\", " + "\"action\":\"" + action + "\", " + "\"method\":\"" + method + "\"}";
	        	logger.debug(str);
	        	
	        	line = "," + action + "," + method + "," + elapsed + "\n";
		        bw.write(line);
        	}
	    }
	    
		mongoClient.close();
		str += "]";
    	logger.debug(str);
		out.print(str);
		
    } catch (IOException ioe) {
	   ioe.printStackTrace();
	}
	finally
	{ 
	   try{
	      if(bw!=null)
		 bw.close();
	   }catch(Exception ex){
	       System.out.println("Error in closing the BufferedWriter"+ex);
	    }
	}


		
		logger.debug(str);
		logger.debug("end getTrialEvents()");
		
		
	}
	
	private String formatDuration(long tstamp, long prevTime) {
		String elapsed = "";
		String seconds = "";
		String remainder = "";

    	long duration = tstamp - prevTime;
		prevTime = tstamp;
		float secs = duration / 1000;
		seconds = Float.toString(secs);
		seconds = seconds.substring(0,seconds.indexOf("."));
		float rem = duration % 1000;
		remainder = Float.toString(rem);
		remainder = remainder.substring(0,remainder.indexOf("."));
		elapsed = seconds + "." + remainder;
		return elapsed;
	}


}
