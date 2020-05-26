package edu.wpi.fh2t.servlets;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;

import com.mysql.jdbc.Connection;
import com.mysql.jdbc.PreparedStatement;

import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.ResourceBundle;

public class getProblemHdrs extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public getProblemHdrs() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		PrintWriter out = response.getWriter();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");

		logger.setLevel(Level.DEBUG);
		
		logger.debug("getProblemHdrs servlet starting");			

		String experimentID = "";
		if (request.getParameter("experimentID") != null) {
			experimentID = request.getParameter("experimentID");
		}

		
		String problemId = "";
		if (request.getParameter("problemId") != null) {
			problemId = request.getParameter("problemId");			
		}
		
		String start_state = "";
		String goal_state = "";
		String best_step = "";
		

		String str = "{";

		String fh2tquery = "select problem, answer, bestStep from problems where ID = " + Integer.parseInt(problemId);		
		logger.debug("fh2tquery=" + fh2tquery);
		Connection con = null;
		try {
			Class.forName((String) getServletContext().getInitParameter("dbClass"));
			con = (Connection) DriverManager.getConnection ((String) getServletContext().getInitParameter("dbUrl"),(String) getServletContext().getInitParameter("dbUser"),(String) getServletContext().getInitParameter("dbPwd"));
			PreparedStatement pstmt = (PreparedStatement)con.prepareStatement(fh2tquery);
			ResultSet rs = pstmt.executeQuery(fh2tquery);
			if (rs.next()) {
				start_state = rs.getString("problem");
				goal_state = rs.getString("answer");
				best_step = rs.getString("bestStep");
				logger.debug(start_state);			
				logger.debug(goal_state);			
				logger.debug(best_step);	
				str += "\"start_state\":\"" + start_state + "\",";
				str += "\"goal_state\":\"" + goal_state + "\",";
				str += "\"best_step\":\"" + best_step + "\"";
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
		
		

	    str += "}";
		out.print(str);
		logger.debug(str);
		logger.debug("end getProblemHdrs()");
				
	}
}
