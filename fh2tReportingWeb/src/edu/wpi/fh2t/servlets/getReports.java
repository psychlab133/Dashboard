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

import com.mysql.jdbc.Connection;
import com.mysql.jdbc.Statement;
import com.mysql.jdbc.PreparedStatement;

import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.ResourceBundle;

public class getReports extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public getReports() {
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

		String selector = "FS0101-%";
		
		logger.debug("getReports servlet starting");			

		String str = "";
		
		// <div class='row'><div class='col-2'><h2></h2></div><div class='col-8'><button type='button' class='btn btn-danger btn-lg ml-1 ' onclick='resetReports()'>" + rb.getString("reset") + "</button><button type='button' class='btn btn-primary btn-lg ml-1 ' onclick='runTestQuery()'>" + rb.getString("submit") + "</button></div><div class='col-2'><h2></h2></div></div>
		
		out.print("<div class='row'><div class='col-4 selection-header'><h4>" + rb.getString("reports") + "</h4></div></div><div class='row'><div class='col-4'>");	

		out.print("<div class='col-4'><select id='reportsSelections' class='custom-select' size='8' onChange='getReport();' >");


		str = "";

		String query = "select ID as RID, rptName as RNAME, rptDescription as RDESC, role as ROLE, rptTableList as RTABLES from reports WHERE role = 1 ;";		
		logger.debug("query=" + query);
		Connection con = null;
		try {
			Class.forName((String) getServletContext().getInitParameter("rptdbClass"));
			con = (Connection) DriverManager.getConnection ((String) getServletContext().getInitParameter("rptdbUrl"),(String) getServletContext().getInitParameter("rptdbUser"),(String) getServletContext().getInitParameter("rptdbPwd"));
			PreparedStatement pstmt = (PreparedStatement)con.prepareStatement(query);
			ResultSet rs = pstmt.executeQuery(query);
			while (rs.next()) {
				str += "<option style='background-color:" + colorName + ";' value='" + rs.getString("RNAME") + "'> " + rs.getString("RDESC") + "</option>";
				logger.debug(str);
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
		
		logger.debug("str=" + str);

		out.print(str);
		out.print("</select></div>");
		out.print("</div></div>");

	}
}
