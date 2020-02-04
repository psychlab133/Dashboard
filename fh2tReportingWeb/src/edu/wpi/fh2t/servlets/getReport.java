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

public class getReport extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public getReport() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");

		logger.setLevel(Level.DEBUG);
		
		PrintWriter out = response.getWriter();

		String reportName = "";
		if (request.getParameter("reportname") != null) {
			reportName = request.getParameter("reportname");
		}

		logger.debug("getReport servlet starting");			

		String str = "";
		

		switch (reportName) {
			case "w-comparison" :
				str += "1:18,15,12,4,5,6,7,8,9,10,8,6,5,2,0:18,16,13,15,15,6,7,8,9,10,8,6,5,2,3";
				break;
			case "w-left-graph" :
				str += "1:18,15,12,4,5,6,7,8,9,10,8,6,5,2,0: ";
				break;
			case "w-right-graph" :
				str += "1: :18,16,13,15,15,6,7,8,9,10,8,6,5,2,3";
				break;
//			case "w-two-graphs" :
//				str += "2:18,15,12,4,5,6,7,8,9,10,8,6,5,2,0:18,16,13,15,15,6,7,8,9,10,8,6,5,2,3";
//				break;
			case "w-two-graphs" :
				str += "3:18,15,12,4,5,6,7,8,9,10,8,6,5,2,0:18,16,13,15,15,6,7,8,9,10,8,6,5,2,3";
				break;
		}
		
		logger.debug(str);
		out.print(str);

	}
}
