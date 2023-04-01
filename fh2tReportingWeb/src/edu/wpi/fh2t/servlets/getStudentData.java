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
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.stream.Collectors;
public class getStudentData extends HttpServlet {
	// filter_ar array description
	//	filter_ar[0] : problem number
	//	filter_ar[1] : school number
	//	filter_ar[2] : teacher number
	//	filter_ar[3] : class number
	//	filter_ar[4] : sort-by
	//	filter_ar[5] : sort-order
	//	filter_ar[6] : studentID
	private static final int PROBLEMS = 0;
	private static final int SCHOOLS = 1;
	private static final int TEACHERS = 2;
	private static final int CLASSROOMS = 3;
	private static final int SORT_BY = 4;
	private static final int SORT_ORDER = 5;
	private static final int STUDENTS = 6;

	private static final long serialVersionUID = 1L;
	private static final String selectionEnd= "</select></div></div></div>";
	
	public getStudentData() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		
		long startTime = System.nanoTime();
		
		HttpSession session = request.getSession();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");

		//logger.setLevel(Level.DEBUG);
		
		PrintWriter out = response.getWriter();
		
		// parse parameters

		String schColor = "white";
		String claColor = "white";
		String teaColor = "white";
		String stuColor = "white";
		
		if (request.getParameter("schColor") != null) {
			schColor = request.getParameter("schColor");			
		}
		if (request.getParameter("claColor") != null) {
			claColor = request.getParameter("claColor");			
		}
		if (request.getParameter("teaColor") != null) {
			teaColor = request.getParameter("teaColor");			
		}
		if (request.getParameter("stuColor") != null) {
			stuColor = request.getParameter("stuColor");			
		}
		
		
		String filter= "------";
		if (request.getParameter("filter") != null) {
			filter = request.getParameter("filter");
		}

		String filter_ar[] = filter.split("-", -1); // parse filter Param

		String problemId = filter_ar[PROBLEMS];
		if (problemId.equals("")) {
			problemId = "121"; // default
		}
		
		int sortBy = -1; 
		if (!filter_ar[SORT_BY].equals("")) {
			sortBy = Integer.parseInt(filter_ar[SORT_BY]);
		}
		
		int sortOrder = -1;
		if (!filter_ar[SORT_ORDER].equals("")) {
			sortOrder = Integer.parseInt(filter_ar[SORT_ORDER]);
		}
		

		String collectionName = (String) session.getAttribute("expAggregation");
		logger.debug("collection  = " + collectionName);

		logger.debug("getStudentData servlet using filter: " + filter);			

		String str_Sch = getSelectionHeader("schools", rb);
		String str_Tea = getSelectionHeader("teachers", rb);
		String str_Cla = getSelectionHeader("classrooms", rb);
		String str_Sort_by = getSelectionHeader("sortby", rb);
		String str_Sort_order = getSelectionHeader("sortorder", rb);
		String str_Stu= getSelectionHeader("students", rb);
		// need to add sort by, sort order, and students
		

		String query = "";
		if (filter.equals("------")) {
			logger.debug("unfiltered");
			query = "select username as UNAME, StuID, SchID, TeaID, ClaID from dashboard_view where not ClaID = '' " +
					"and not TeaID = ''";					
		}
		else {
			query = "select username as UNAME, StuID, SchID, TeaID, ClaID from dashboard_view where not ClaID = '' " +
						"and not TeaID = ''";
			if (!filter_ar[SCHOOLS].equals("")) {
				query+= " and SchID = '" + filter_ar[SCHOOLS] + "'";
			}
			if (!filter_ar[TEACHERS].equals("")) {
				query+= " and TeaID = '" + filter_ar[TEACHERS] + "'";		
			}
			if (!filter_ar[CLASSROOMS].equals("")) {
				query+= " and ClaID = '" + filter_ar[CLASSROOMS] + "'";
			}
		}
		query += ";";
		logger.debug("query=" + query);
		Connection con = null;
		List<String> studentIDList = new ArrayList<String>();
		List<String> userNameList = new ArrayList<String>();
		List<String> schoolList = new ArrayList<String>();
		List<String> teacherList = new ArrayList<String>();
		List<String> classList = new ArrayList<String>();
		
		
		try {

			MongoClient mongoClient = new MongoClient("localhost", 7010);
			logger.debug("MongoClient created");
			MongoDatabase experimentDB = mongoClient.getDatabase("gm-logs");
			logger.debug("User database=" + experimentDB.getName());
			MongoCollection<Document> collection = (MongoCollection <Document>) experimentDB.getCollection(collectionName);	
			
			Class.forName((String) getServletContext().getInitParameter("dbClass"));
			con = (Connection) DriverManager.getConnection ((String) getServletContext().getInitParameter("iesdbUrl"),(String) getServletContext().getInitParameter("iesdbUser"),(String) getServletContext().getInitParameter("iesdbPwd"));
			PreparedStatement pstmt = (PreparedStatement)con.prepareStatement(query);
			
			
			
			System.out.println("TIME BEFORE IESDB QUERY: " + (System.nanoTime() - startTime)/1000000);
			startTime = System.nanoTime();
			
			
			
			ResultSet rs = pstmt.executeQuery(query);
			while (rs.next()) {
				studentIDList.add(rs.getString("StuId"));
				userNameList.add(rs.getString("UNAME"));
				schoolList.add(rs.getString("SchID"));
				teacherList.add(rs.getString("TeaID"));
				classList.add(rs.getString("ClaID"));
			}
			
			
			System.out.println("TIME FOR IESDB QUERY: " + (System.nanoTime() - startTime)/1000000);
			startTime = System.nanoTime();
			
			
			
			
			List<List<String>> sortedStudentData = getSortedList(userNameList, studentIDList, schoolList, teacherList, classList, logger, collection, problemId, sortBy, sortOrder);
			
			
			
			
			System.out.println("TIME FOR getSortedList function call: " + (System.nanoTime() - startTime)/1000000);
			startTime = System.nanoTime();
			
			
			
			
			str_Sch+= getSelectBody(sortedStudentData.get(0),schColor); //school
			str_Sch+=selectionEnd;
			str_Tea+= getSelectBody(sortedStudentData.get(1),teaColor); //teacher
			str_Tea+=selectionEnd;
			str_Cla+= getSelectBody(sortedStudentData.get(2),claColor); //class
			str_Cla+=selectionEnd;
			str_Sort_by+= getSelectBody(sortedStudentData.get(3),stuColor); //sort by
			str_Sort_by+=selectionEnd;
			str_Sort_order+= getSelectBody(sortedStudentData.get(4),stuColor); //sort order
			str_Sort_order+=selectionEnd;
			str_Stu+= getSelectBody(sortedStudentData.get(5),stuColor); //sort order
			str_Stu+=selectionEnd;
			
			
			
			System.out.println("TIME FOR PARSING DATA INTO HTML: " + (System.nanoTime() - startTime)/1000000);

			
			
			
			
			
//		}
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
		
		// ugly code, did not want unneeded gson import but no reason to have a seperate function for this
		String data_json = "{";
		data_json+="\"school\":";
		data_json+="\"";
		data_json+=str_Sch;
		data_json+="\"";
		data_json+=",";
		data_json+="\"teacher\":";
		data_json+="\"";
		data_json+=str_Tea;
		data_json+="\"";
		data_json+=",";
		data_json+="\"class\":";
		data_json+="\"";
		data_json+=str_Cla;
		data_json+="\"";
		data_json+=",";
		data_json+="\"sortby\":";
		data_json+="\"";
		data_json+=str_Sort_by;
		data_json+="\"";
		data_json+=",";
		data_json+="\"sortorder\":";
		data_json+="\"";
		data_json+=str_Sort_order;
		data_json+="\"";
		data_json+=",";
		data_json+="\"student\":";
		data_json+="\"";
		data_json+=str_Stu;
		data_json+="\"";
		data_json+="}";
		out.print(data_json);
		
	}
	
	private List<List<String>> getSortedList(List<String> userNameList, List<String> studentIDList, List<String> schoolList, 
			List<String> teacherList, List<String> classList, Logger logger, MongoCollection<Document> collection, String problemId, int sortBy, int sortOrder){
		
		
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
	    List<String> sortedSchoolList = new ArrayList<String>();
	    List<String> sortedTeacherList = new ArrayList<String>();
	    List<String> sortedClassList = new ArrayList<String>();
	    List<String> sortedStudentIDList = new ArrayList<String>();
	    Map<String, String> sortedStudentList = new HashMap<String, String>();
	    
		String problemPrefix = "p" + problemId;
		logger.debug("problemPrefix=" + problemPrefix);	
		String sortField = "";
	    
	    sortQueryList.add(new BasicDBObject("studentID", new BasicDBObject("$in", userNameList)));
    
		
		if (sortBy != -1 && sortOrder != -1) {
			sortField = problemPrefix + sortMetrics[sortBy];
//		    sortQuery.put(sortField, new BasicDBObject("$ne", "N/A"));
		    sortQueryList.add(new BasicDBObject(sortField, new BasicDBObject("$ne", "N/A")));			
		}
	    
	

	    sortQueryList.add(new BasicDBObject(problemPrefix+"_completed", "1"));
	    sortQuery.put("$and", sortQueryList);

	    
	    
	    FindIterable<Document> findIterable = (FindIterable<Document>) collection.find(sortQuery).projection(Projections.include("studentID", sortField));

	    
	    
		Iterator<Document> iterator = findIterable.iterator();

		Document metric = null;
		String sortedUser = "";
		String sortedSchool = "";
		String sortedClass = "";
		String sortedTeacher = "";
		String sortedStudent = "";
		String studentNum = "";
		
		while(iterator.hasNext()) {
			metric = (Document) iterator.next();
			sortedUser = (String) metric.get("studentID"); // AKA username, db calls username as studentID
			int indexOfStudent = userNameList.indexOf(sortedUser);
			sortedSchool = schoolList.get(indexOfStudent);
			sortedClass = classList.get(indexOfStudent);
			sortedTeacher = teacherList.get(indexOfStudent);
			sortedStudent = studentIDList.get(indexOfStudent);
			if (!sortedSchoolList.contains(sortedSchool)) {
				sortedSchoolList.add(sortedSchool);
			}
			if (!sortedTeacherList.contains(sortedTeacher)) {
				sortedTeacherList.add(sortedTeacher);
			}
			if (!sortedClassList.contains(sortedClass)) {
				sortedClassList.add(sortedClass);
			}
			if (sortBy != -1 && sortOrder != -1) {
				studentNum = (String) metric.get(sortField);				
				sortedStudentList.put(studentIDList.get(indexOfStudent), studentNum);
				}
			else {
				sortedStudentIDList.add(studentIDList.get(indexOfStudent));
			}
		}
		
		Comparator<String> cmp = new Comparator<String>()
	    {
	        @Override
	        public int compare(String o1, String o2)
	        {
	            return new Integer(o1)
	                .compareTo(new Integer(o2));
	        }

	    };
		Collections.sort(sortedSchoolList,cmp);
		Collections.sort(sortedTeacherList,cmp);
		Collections.sort(sortedClassList,cmp);
		// sort by custom sort order
		if (sortBy != -1 && sortOrder != -1) {
			sortedStudentIDList = sortedStudentList.entrySet()
					.stream()
					.sorted((i1, i2)
								-> sortOrder == 0 ? (i1.getValue().compareTo(
									i2.getValue()) == 0 ? i1.getKey().compareTo(
									i2.getKey()) : i1.getValue().compareTo(
									i2.getValue())) : (i2.getValue().compareTo(
											i1.getValue()) == 0 ? i1.getKey().compareTo(
													i2.getKey()) : i2.getValue().compareTo(
													i1.getValue())) ).map(Map.Entry::getKey)
					.collect(Collectors.toList());
		}else {
			Collections.sort(sortedStudentIDList, cmp);
		}


		List<List<String>> output = new ArrayList<>();
		output.add(sortedSchoolList);
		output.add(sortedTeacherList);
		output.add(sortedClassList);
		output.add(getSortByList());
		output.add(getSortOrderList());
		output.add(sortedStudentIDList);

		return output;
	}
	
	private String getSelectBody(List<String> selectData, String tableColor) {
		String output="";
		for (String data: selectData) {
			output+="<option style='background-color:" + tableColor + ";' value='" + data + "'> " + data + "</option>";
		}
		return output;
	}
	
	private List<String> getSortByList() {
		String sortBy[] = {
				"Number of steps",
				"Number of go-backs",
				"Number of resets",
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
		return new ArrayList<>(Arrays.asList(sortBy));
	}
	
	private List<String> getSortOrderList() {
		String sortOrder[] = {
				"Ascending",
				"Descending"
		};
		return new ArrayList<>(Arrays.asList(sortOrder));
	}
	
	private String getSelectionHeader(String type, ResourceBundle rb) {
		String returnStr = "";
		returnStr+="<div class='row'><div class='col-4 selection-header'><h4>" + rb.getString(type) + "</h4></div></div><div class='row'><div class='col-4'>";
		if (type.equals("schools")) {
			returnStr+="<div class='col-4'><select id='schoolsSelections' class='custom-select' size='1' onchange=setSchool();>";
			returnStr+="<option style='background-color:white;' value=''>Select School</option>";
		} else if (type.equals("classrooms")) {
			returnStr+="<div class='col-4'><select id='classroomsSelections' class='custom-select' size='1' onchange=setClassroom();>";
			returnStr+="<option style='background-color:white;' value=''>Select Classroom</option>";
		} else if (type.equals("teachers")){
			returnStr+="<div class='col-4'><select id='teachersSelections' class='custom-select' size='1' onchange=setTeacher();>";
			returnStr+="<option style='background-color:white;' value=''>Select Teacher</option>";
		} else if (type.equals("students")){
			returnStr += "<div class='col-4'><select id='usernamesSelections' class='custom-select' size='1' onchange=setStudent();>";
			returnStr += "<option style='background-color:white;' value=''>Select Student</option>";
		} else if (type.equals("sortby")){
			returnStr +="<div class='col-4'><select id='sortBySelections' class='custom-select' size='0' min-width:90%; onchange=setSortedList();>";
			returnStr +="<option style='background-color:white;' value=''></option>";
		} else if (type.equals("sortorder")){
			returnStr +="<div class='col-4'><select id='sortOrderSelections' class='custom-select' size='0' min-width:90%; onchange=setSortedList();>";
			returnStr +="<option style='background-color:white;' value=''></option>";
		}
		return returnStr;
	}
	
	
	

}
