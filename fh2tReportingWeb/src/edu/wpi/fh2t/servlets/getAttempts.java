package edu.wpi.fh2t.servlets;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import com.mysql.jdbc.Connection;
import com.mysql.jdbc.Statement;
import com.mysql.jdbc.PreparedStatement;

import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.ResourceBundle;

public class getAttempts extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public getAttempts() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		PrintWriter out = response.getWriter();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");

		String colorName = "Gray";
		if (request.getParameter("tablecolor") != null) {
			colorName = request.getParameter("tablecolor");
		}

		String level="";
		if (request.getParameter("level") != null) {
			level = request.getParameter("level");
		}

		logger.debug("getAttempts servlet starting");			

		out.print("<div class='row'><div class='col-4'><h2>" + rb.getString("attempts") + "</h2></div></div><div class='row'><div class='col-2'><h2></h2></div><div class='col-8'><button type='button' class='btn btn-danger btn-lg ml-1 ' onclick='resetAttempts()'>" + rb.getString("reset") + "</button><button type='button' class='btn btn-primary btn-lg ml-1 ' onclick='getColumns(" + level + ")'>" + rb.getString("columns") + "</button></div><div class='col-2'><h2></h2></div></div><div class='row'><div class='col-4'>");
		out.print("<div class='col-4'><select id='attemptsSelections' class='custom-select' size='10' multiple='multiple'>");

		String str = "";
		//String query = "select ID,userID,derivationReport from attempts where NOT problemID = "-1" order by userID,problemID;";		
		String query = "select derivationreport as REPORT, ID as id, problemID as PROBLEM, userID as USER from attempts where NOT problemID = '-1' order by problemID;";		
		logger.debug("query=" + query);
		Connection con = null;
		try {
			Class.forName((String) getServletContext().getInitParameter("dbClass"));
			con = (Connection) DriverManager.getConnection ((String) getServletContext().getInitParameter("dbUrl"),(String) getServletContext().getInitParameter("dbUser"),(String) getServletContext().getInitParameter("dbPwd"));
			PreparedStatement pstmt = (PreparedStatement)con.prepareStatement(query);
			ResultSet rs = pstmt.executeQuery(query);
			while (rs.next()) {
				String problem = rs.getString("PROBLEM");
				String report  = rs.getString("REPORT");
				if ((problem == null) || (report == null)) {
					logger.debug("null");
					continue;
				}
				if (report.length() > 26) {
					report = report.substring(0, 24) + "...";
				}
				String temp = "<option style='background-color:" + colorName + ";' value='" + rs.getString("id") + "'> " + rs.getString("PROBLEM") + "   " + report + "</option>";
				str += temp;
				logger.debug(temp);
				//str += "<option style='background-color:" + colorName + ";' value='" + rs.getString("id") + "'> " + rs.getString("PROBLEM") + " " + report + "</option>";
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
