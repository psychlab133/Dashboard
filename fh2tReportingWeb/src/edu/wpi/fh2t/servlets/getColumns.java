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

public class getColumns extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public getColumns() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		
		Logger logger = (Logger) session.getAttribute("logger");
		logger.setLevel(Level.DEBUG);
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");

		PrintWriter out = response.getWriter();

		String tableName = request.getParameter("tablename");
		String colorName = "Gray";
		if (request.getParameter("tablecolor") != null) {
			colorName = request.getParameter("tablecolor");
		}
		
//		String idString = "'Options'";
		out.print("<div class='row'><div class='col-4'><select id='Options' class='custom-select' size='10' multiple='multiple'>");

		String str = "";

		String query = "SELECT COLUMN_NAME FROM information_schema.columns WHERE table_name='" + tableName + "'AND TABLE_SCHEMA='fh2treporting';";
		logger.debug("query=" + query);
		Connection con = null;
		try {
			Class.forName((String) getServletContext().getInitParameter("dbClass"));
			con = (Connection) DriverManager.getConnection ((String) getServletContext().getInitParameter("dbUrl"),(String) getServletContext().getInitParameter("dbUser"),(String) getServletContext().getInitParameter("dbPwd"));
			PreparedStatement pstmt = (PreparedStatement)con.prepareStatement(query);
			ResultSet rs = pstmt.executeQuery(query);
			while (rs.next()) {
				str += "<option style='background-color:" + colorName + ";'>" + rs.getString(1) + "</option>";
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
		out.print("</select></div></div>");

	}
}
