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

public class getProblems extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public getProblems() {
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

		logger.debug("getProblems servlet starting");			
		
//		out.print("<div class='row'><div class='col-4'><h4>" + rb.getString("problems") + "</h4></div></div><div class='row'><div class='col-2'><h4></h4></div><div class='col-8'><button type='button' class='btn btn-danger btn-sm ml-1 ' onclick='resetStudents()'>" + rb.getString("reset") + "</div><div class='col-2'><h4></h4></div></div><div class='row'><div class='col-4'>");	
		out.print("<div class='row'><div class='col-4 selection-header'><h4>" + rb.getString("problems") + "</h4></div></div><div class='row'><div class='col-4'>");	

		//out.print("<div class='row'><div class='col-4'><h2>" + rb.getString("problems") + "</h2></div></div><div class='row'><div class='col-2'><h2></h2></div><div class='col-8'><button type='button' class='btn btn-danger btn-lg ml-1 ' onclick='resetProblems()'>" + rb.getString("reset") + "</button><button type='button' class='btn btn-primary btn-lg ml-1 ' onclick='getColumns(" + level + ")'>" + rb.getString("columns") + "</button></div><div class='col-2'><h2></h2></div></div><div class='row'><div class='col-4'>");
		out.print("<div class='col-4'><select id='problemsSelections' class='custom-select' size='8'  onchange=setProblem();>");

		String str = "";
	
		String query = "select problem as PROBLEM, ID as id from problems;";		
		logger.debug("query=" + query);
		Connection con = null;
		try {
			Class.forName((String) getServletContext().getInitParameter("dbClass"));
			con = (Connection) DriverManager.getConnection ((String) getServletContext().getInitParameter("dbUrl"),(String) getServletContext().getInitParameter("dbUser"),(String) getServletContext().getInitParameter("dbPwd"));
			PreparedStatement pstmt = (PreparedStatement)con.prepareStatement(query);
			ResultSet rs = pstmt.executeQuery(query);
			while (rs.next()) {
				String desc = rs.getString("PROBLEM");
				if (desc.length() > 15) {
					desc = desc.substring(0, 12) + "...";
				}

				str += "<option style='background-color:" + colorName + ";' value='" + rs.getString("id") + "'> "+ rs.getString("id") + ". " + desc + "</option>";
			}
			rs.close();
		    pstmt.close();
			con.close();
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
