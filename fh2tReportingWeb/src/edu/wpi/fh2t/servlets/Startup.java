package edu.wpi.fh2t.servlets;

import java.io.IOException;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

import javax.servlet.RequestDispatcher;
import javax.servlet.Servlet;
import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.FileReader;
import java.io.BufferedReader;
import java.io.IOException;


import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;
import org.bson.Document;
import org.bson.conversions.Bson;

import com.mysql.jdbc.Connection;
import com.mysql.jdbc.PreparedStatement;

import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.MongoIterable;
import com.mongodb.BasicDBObject;
import com.mongodb.MongoClient; 
import com.mongodb.MongoCredential;

import org.apache.log4j.Level;

/**

 * Servlet implementation class Startup
 */

public class Startup extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Logger logger;
	
    /**
     * @see HttpServlet#HttpServlet()
     */
    public Startup() {
        super();
        // TODO Auto-generated constructor stub
		System.out.println("Startup - no param");
    }

	/**
	 * @see Servlet#init(ServletConfig)
	 */
	@SuppressWarnings("deprecation")
	public void init(ServletConfig config) throws ServletException {
		// TODO Auto-generated method stub
		System.out.println("Startup - with param");
		ServletContext ctx = config.getServletContext();
		System.out.println("ContextPath = " + ctx.getContextPath());
		String realPath = ctx.getRealPath("/");
		System.out.println("realPath = " + realPath);
        //init(ctx.getRealPath("/"));
        
		logger = Logger.getLogger("MyLogger");

		try {	
		    //PropertiesConfigurator is used to configure logger from properties file
			String filePath = realPath + "WebContent\\WEB-INF\\classes\\log4j.properties";
			System.out.println("filePath = " + filePath);

	        String level = ctx.getInitParameter("loggingLevel");
	        if (level == "DEBUG") {
	        	logger.setLevel(Level.DEBUG);
	        }
	        else {
	        	logger.setLevel(Level.INFO);
	        }
		}	
		catch (Exception e) {
			System.out.println("Exception = " + e.getMessage());
		}
		
		logger.setLevel(Level.DEBUG); 		

		Enumeration<String> ae = ctx.getInitParameterNames();
		if (ae.hasMoreElements()) {
			while (ae.hasMoreElements()) {
				String s = ae.nextElement();
				System.out.println("Init Parameter: " + s + "=" + ctx.getInitParameter(s));
			}
		}
		
		try {
			ResourceBundle rb = ResourceBundle.getBundle("fh2tReporting");
			String str = rb.getString("title");
			logger.info(str);
		}
		catch (Exception e) {
			System.out.println("Exception = " + e.getMessage());
		}
        
		logger.info("Starting version 1.0.0");
        String dbUrl = ctx.getInitParameter("dbUrl");
        logger.debug("dbUrl=" + dbUrl);
        String dbClass = ctx.getInitParameter("dbClass");
        logger.debug("dbClass=" + dbClass);
        String dbUser = ctx.getInitParameter("dbUser");
        String dbPwd = ctx.getInitParameter("dbPwd");
        String dbSchema = ctx.getInitParameter("dbSchema");
        
		Connection con = null;
		try {
			Class.forName(dbClass);
			con = (Connection) DriverManager.getConnection (dbUrl,dbUser,dbPwd);
			String query = "SELECT COLUMN_NAME FROM information_schema.columns WHERE table_name='usernames' AND TABLE_SCHEMA='" + dbSchema + "';";
			PreparedStatement pstmt = (PreparedStatement)con.prepareStatement(query);
			ResultSet rs = pstmt.executeQuery(query);
			while (rs.next()) {
				logger.debug(rs.getString(1));
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

        String iesdbUrl = ctx.getInitParameter("iesdbUrl");
        logger.debug("iesdbUrl=" + iesdbUrl);
        String iesdbClass = ctx.getInitParameter("iesdbClass");
        logger.debug("iesdbClass=" + iesdbClass);
        String iesdbUser = ctx.getInitParameter("iesdbUser");
        String iesdbPwd = ctx.getInitParameter("iesdbPwd");
        String iesdbSchema = ctx.getInitParameter("iesdbSchema");
        
		Connection iescon = null;
		try {
			Class.forName(iesdbClass);
			iescon = (Connection) DriverManager.getConnection (iesdbUrl,iesdbUser,iesdbPwd);
			String query = "SELECT COLUMN_NAME FROM information_schema.columns WHERE table_name='usernames' AND TABLE_SCHEMA='" + iesdbSchema + "';";
			PreparedStatement pstmt = (PreparedStatement)iescon.prepareStatement(query);
			ResultSet rs = pstmt.executeQuery(query);
			while (rs.next()) {
				logger.debug(rs.getString(1));
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
				iescon.close();
			}
			catch(java.sql.SQLException e) {
				logger.error(e.getMessage());
				logger.error(e.fillInStackTrace());
			}			
		}


	}


	/**
	 * @see Servlet#getServletConfig()
	 */
	public ServletConfig getServletConfig() {
		// TODO Auto-generated method stub
		return null;
	}

	/**
	 * @see Servlet#getServletInfo()
	 */
	public String getServletInfo() {
		// TODO Auto-generated method stub
		return null; 
	}

	public void init(String realPath) {
		// TODO Auto-generated method stub
	
		logger = Logger.getLogger("MyLogger");

		try {	
		    //PropertiesConfigurator is used to configure logger from properties file

			
			
			PropertyConfigurator.configure("C:/WPI/FH2T/Efficacy/fh2tReportingWeb/WebContent/WEB-INF/classes/log4j.properties");

			logger.setLevel(Level.DEBUG);
		    
		    //System.out.println("Logger class = " + Logger.class.toString());

			//System.out.println("Log name is " + logger.getName());

			logger.info("I'm logging");
			
			if (logger.isInfoEnabled()) {
				//System.out.println("INFO is enabled");
				logger.info("I'm infoing");				
			}
			else {
				System.out.println("INFO is not enabled");
			}

			if (logger.isDebugEnabled()) {
				logger.debug("I'm debugging");
			}
			else {
				System.out.println("DEBUG is not enabled");
			}
		}
		catch (Exception e) {
			System.out.println("Exception = " + e.getMessage());
		}
		
		

		try {
			ResourceBundle rb = ResourceBundle.getBundle("fh2tReporting");
			String str = rb.getString("title");
			logger.info(str);
		}
		catch (Exception e) {
			logger.debug("Exception = " + e.getMessage());
		}
        //PropertiesConfigurator is used to configure logger from properties file
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		try {
			
			HttpSession mySession = request.getSession();
			
			mySession.setAttribute("logger", logger);
			
			ResourceBundle rb = ResourceBundle.getBundle("fh2tReporting");
			mySession.setAttribute("rb", rb);
			

			Enumeration<String> ie = request.getParameterNames();
			if (ie.hasMoreElements()) {
				while (ie.hasMoreElements()) {
					String s = ie.nextElement();
					logger.debug("Request Parameter: " + s + "=" + request.getParameter(s) );
				}
			}
			else {
				logger.debug("Request has no Parameters");
			}
			
			Enumeration<String> rae = request.getAttributeNames();
			if (rae.hasMoreElements()) {
				while (rae.hasMoreElements()) {
					String s = rae.nextElement();
					logger.debug("Request Attribute: " + s + "=" +  request.getAttribute(s));
				}
			}
			else {
				logger.debug("Request has no Attributes");
			}

			//ConvertTableSQltoMongoDB("usernames","testers",mySession);
			
			//ConvertCSVFile_to_MongoDBCollection("wpi_ies_study_fall_19_trials","trials",mySession);
			
			//ShowDBCollection("trials",mySession);
			
			//ShowDBCollection("trials",mySession);

			RequestDispatcher dispatcher = request.getRequestDispatcher("/fh2tLogin.jsp");    
			dispatcher.forward(request, response);

		}
		catch (Exception e) {
			logger.debug("Exception = " + e.getMessage());
		}

	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
	}

	
	public boolean ImportTrialsJson() {
		boolean result = false;
		
		
		
		return result;
	}
	
	
	public void ConvertTableSQltoMongoDB(String SrcTable, String DstTable, HttpSession session) {
		
		ServletContext sc = session.getServletContext();
		Logger logger = (Logger) session.getAttribute("logger");

		MongoIterable<String> temp;
		MongoClient mongoClient = new MongoClient("localhost", 7010);
		logger.debug("MongoClient created");
		//mongoClient.getUsedDatabases().forEach(System.out::println);
		MongoDatabase userdb = mongoClient.getDatabase("gm-users");
		logger.debug("User database=" + userdb.getName());
		temp = userdb.listCollectionNames();
		logger.debug("First userdb collection=" + temp.first());
		
		
		MongoCollection<Document> userDocuments;

		userdb.getCollection(DstTable).drop();

        userDocuments = userdb.getCollection(DstTable);
        userDocuments.drop();
        
        List<Document> testUsers = new ArrayList<>();
		
		String query = "select * from " + SrcTable + "";		
		logger.debug("query=" + query);
		Connection con = null;
		try {
			Class.forName((String) sc.getInitParameter("dbClass"));
			con = (Connection) DriverManager.getConnection ((String) sc.getInitParameter("dbUrl"),(String) sc.getInitParameter("dbName"),(String) sc.getInitParameter("dbPwd"));
			PreparedStatement pstmt = (PreparedStatement)con.prepareStatement(query);
			logger.debug("before executeQuery");
			ResultSet rs = pstmt.executeQuery(query);
			while (rs.next()) {
				logger.debug("resultset");
				Document document = new Document();
				ResultSetMetaData metaData = rs.getMetaData();
				int fieldCount = metaData.getColumnCount(); //number of column
				String line = "";
				for (int i=1;i <= fieldCount;i++) {
					logger.debug((String) metaData.getColumnLabel(i));
					int t = metaData.getColumnType(i);
					//System.out.println("columnType=" + t);
					if (t == 4) {
				        line = "{\n" + (String) metaData.getColumnLabel(i) + ": " + String.valueOf(rs.getInt(metaData.getColumnLabel(i))) + "\n}";
				        testUsers.add(Document.parse(line));
					}
					else {
				        line = "{\n" + (String) metaData.getColumnLabel(i) + ": " + String.valueOf(rs.getString(metaData.getColumnLabel(i))) + "\n}";
				        testUsers.add(Document.parse(line));
					}
				}
			}
			rs.close();
		    pstmt.close();
			userDocuments.insertMany(testUsers);
			logger.debug("AfterUernames");
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
				mongoClient.close();
			}
			catch(java.sql.SQLException e) {
				logger.error(e.getMessage());
				logger.error(e.fillInStackTrace());
			}			
		}
		
	}
	
	
	public void ConvertCSVFile_to_MongoDBCollection(String ExperimentID, String collectionName, HttpSession session) {
		
		ServletContext sc = session.getServletContext();
		Logger logger = (Logger) session.getAttribute("logger");

		MongoIterable<String> temp;
		MongoClient mongoClient = new MongoClient("localhost", 7010);
		logger.debug("MongoClient created");
		MongoDatabase experimentDB = mongoClient.getDatabase("gm-users");
		logger.debug("User database=" + experimentDB.getName());
		temp = experimentDB.listCollectionNames();
		logger.debug("First experimentDB collection=" + temp.first());
		
		
		MongoCollection<Document> userDocuments;
		experimentDB.getCollection(collectionName).drop();
        userDocuments = experimentDB.getCollection(collectionName);
        userDocuments.drop();
        List<Document> trialsArray = new ArrayList<>();
        String csvPath = "C:\\WPI\\" + ExperimentID + "\\" + collectionName + ".csv";

		logger.setLevel(Level.INFO);

        BufferedReader csvReader=null;
        String line = "";
       	String[] keys = null;
       	String[] values = null;
       	boolean needsComma = false;
       	String delim = "XyZ";
        try {
        	int rows = 0;
        	String row = "";
        	csvReader = new BufferedReader(new FileReader(csvPath));
        	while ((row = csvReader.readLine()) != null) {
        		if (rows == 0) {
            		keys = row.split(delim);
            		logger.debug("headers" + row);        		
            	}
            	else {
            		logger.debug("values" + row);

            		values = row.split(delim);
            		logger.debug("keys=" + keys.length);
            		logger.debug("values=" + values.length);
            		if (values.length <= 0) {
            			break;
            		}
            		line = "{";
            		for (int i = 0; i< values.length;i++) {
            			if ( i > 0) {
            				if (needsComma) {
            					line += ",";
            				}
            				else {
            					needsComma = true;
            				}
            			}
            			logger.debug(keys[i]);
            			if (values[i].length() == 0) {
            				logger.debug("null at " + i);
            				needsComma = false;
            				continue;
            			}
            			line += keys[i];
            			line += ":";
            			logger.debug("[" + values[i] + "]");
            			line += values[i];
            		}
            		line += "}";
            		logger.debug("line= " + line);
        			trialsArray.add(Document.parse(line));
        			
            	}
      		       		
        			if (rows > 14000) {
        				logger.debug("breaking at " + rows);
        				break;
        			}
        			else {
        				//logger.info("rows= " + rows);
        				rows++;
        			}

        	}
			userDocuments.insertMany(trialsArray);
    		logger.debug("insert them");
            csvReader.close();        	
        }
        catch (IOException ie)
        {
        	logger.error("ooops" + ie.getMessage());
        }
        
		logger.debug("AfterTrialImport");
	}
	
	public void ConvertPaagCSVFile_to_MongoDBCollection(String ExperimentID, String collectionName, HttpSession session) {
		
		ServletContext sc = session.getServletContext();
		Logger logger = (Logger) session.getAttribute("logger");

		MongoIterable<String> temp;
		MongoClient mongoClient = new MongoClient("localhost", 7010);
		logger.debug("MongoClient created");
		MongoDatabase experimentDB = mongoClient.getDatabase("gm-users");
		logger.debug("User database=" + experimentDB.getName());
		temp = experimentDB.listCollectionNames();
		logger.debug("First experimentDB collection=" + temp.first());
		
		
		MongoCollection<Document> userDocuments;
		experimentDB.getCollection(collectionName).drop();
        userDocuments = experimentDB.getCollection(collectionName);
        userDocuments.drop();
        List<Document> trialsArray = new ArrayList<>();
        String csvPath = "C:\\WPI\\" + ExperimentID + "\\" + collectionName + ".csv";

		logger.setLevel(Level.INFO);

        BufferedReader csvReader=null;
        String line = "";
       	String[] keys = null;
       	String[] values = null;
       	boolean needsComma = false;
       	String delim = "XyZ";
        try {
        	int rows = 0;
        	String row = "";
        	csvReader = new BufferedReader(new FileReader(csvPath));
        	while ((row = csvReader.readLine()) != null) {
        		if (rows == 0) {
            		keys = row.split(delim);
            		logger.debug("headers" + row);        		
            	}
            	else {
            		logger.debug("values" + row);

            		values = row.split(delim);
            		logger.debug("keys=" + keys.length);
            		logger.debug("values=" + values.length);
            		if (values.length <= 0) {
            			break;
            		}
            		line = "{";
            		for (int i = 0; i< values.length;i++) {
            			if ( i > 0) {
            				if (needsComma) {
            					line += ",";
            				}
            				else {
            					needsComma = true;
            				}
            			}
            			logger.debug(keys[i]);
            			if (values[i].length() == 0) {
            				logger.debug("null at " + i);
            				needsComma = false;
            				continue;
            			}
            			line += keys[i];
            			line += ":";
            			logger.debug("[" + values[i] + "]");
            			line += values[i];
            		}
            		line += "}";
            		logger.debug("line= " + line);
        			trialsArray.add(Document.parse(line));
        			
            	}
      		       		
        			if (rows > 14000) {
        				logger.debug("breaking at " + rows);
        				break;
        			}
        			else {
        				//logger.info("rows= " + rows);
        				rows++;
        			}

        	}
			userDocuments.insertMany(trialsArray);
    		logger.debug("insert them");
            csvReader.close();        	
        }
        catch (IOException ie)
        {
        	logger.error("ooops" + ie.getMessage());
        }
        
		logger.debug("AfterTrialImport");
	}

	
	public void ShowDBCollection(String collectionName, HttpSession session) {
	
		ServletContext sc = session.getServletContext();
		Logger logger = (Logger) session.getAttribute("logger");
		logger.setLevel(Level.DEBUG);

		MongoIterable<String> temp;
		MongoClient mongoClient = new MongoClient("localhost", 7010);
		logger.debug("MongoClient created");
		MongoDatabase experimentDB = mongoClient.getDatabase("gm-users");
		logger.debug("User database=" + experimentDB.getName());
		temp = experimentDB.listCollectionNames();
		logger.debug("First experimentDB collection=" + temp.first());
	
		MongoCollection<Document> collection = (MongoCollection <Document>) experimentDB.getCollection("trials");
	
		MongoCollection<Document> userDocuments;
		experimentDB.getCollection(collectionName);
		
		logger.debug("search");
		BasicDBObject searchQuery = new BasicDBObject();
		searchQuery.put("id", "_52041860c87ae67c");
		
	    FindIterable<Document> findIterable = (FindIterable<Document>) collection.find(searchQuery);
	    Iterator<Document> iterator = findIterable.iterator();
	    while(iterator.hasNext()){
	        Document trial = (Document) iterator.next();
	        logger.debug("trial=" + trial.toString());

	        logger.debug("trial_id = " + trial.get("id"));
	    }
		mongoClient.close();

		logger.debug("AfterTrialImport");} //end try
	}



