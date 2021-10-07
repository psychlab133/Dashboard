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

public class getSortedList extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public getSortedList() {
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
		String sortBy[] = {
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
		String sortOrder[] = {
				"Ascending",
				"Descending"
		};
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

		String collectionName = (String) session.getAttribute("expAggregation");
		logger.debug("collection  = " + collectionName);

		logger.debug("getSortedList servlet using filter: " + filter);			

		out.print("<div class='row'><div class='col-4 selection-header'><h4>" + rb.getString("sortby") + "</h4></div></div><div class='row'><div class='col-4'>");	
		out.print("<div class='col-4'><select id='sortBySelections' class='custom-select' size='0' min-width:90%; onchange=setSortedList();>");
		out.print("<option style='background-color:white;' value=''></option>");

		for (String sort:sortBy) {
			out.print("<option style='background-color:" + colorName + ";' value='" + sort + "'> " + sort + "</option>");
		}
		
		out.print("</select></div>");
		out.print("</div></div>");
		
		out.print("<div class='row'><div class='col-4 selection-header'><h4>" + rb.getString("sortorder") + "</h4></div></div><div class='row'><div class='col-4'>");	
		out.print("<div class='col-4'><select id='sortOrderSelections' class='custom-select' size='0' min-width:90%; onchange=setSortedList();>");
		out.print("<option style='background-color:white;' value=''></option>");

		for (String sort:sortOrder) {
			out.print("<option style='background-color:" + colorName + ";' value='" + sort + "'> " + sort + "</option>");
		}
		
		out.print("</select></div>");
		out.print("</div></div>");
	}

}
