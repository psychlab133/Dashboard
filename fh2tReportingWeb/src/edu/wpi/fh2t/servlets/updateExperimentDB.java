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

public class updateExperimentDB extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public updateExperimentDB() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		PrintWriter out = response.getWriter();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");

		logger.setLevel(Level.DEBUG);
		
		logger.debug("starting saveExperimentInfo() servlet");

		
		String expAbbr = "";
		if (request.getParameter("expAbbr") != null) {
			expAbbr = request.getParameter("expAbbr");
		}

		String expId = "";
		if (request.getParameter("expId") != null) {
			expId = request.getParameter("expId");
		}

		String expDisplay = "";
		if (request.getParameter("expDisplay") != null) {
			expDisplay = request.getParameter("expDisplay");
		}

		session.setAttribute("expAbbr",expAbbr);
		session.setAttribute("expId",expId);
		session.setAttribute("expDisplay",expDisplay);

		
		// MongoDb collection names
		String expTrials = expId + (String) getServletContext().getInitParameter("gm-trials");
		String expData = expId + (String) getServletContext().getInitParameter("gm-data");
		String expAggregation = expId + (String) getServletContext().getInitParameter("gm-aggregation");
		String expAverages = "2020_01_31_" + expId + (String) getServletContext().getInitParameter("gm-averages");

		// Save names in sesion for 'getter' servlets
		session.setAttribute("expTrials",expTrials);
		session.setAttribute("expData",expData);
		session.setAttribute("expAggregation",expAggregation);
		session.setAttribute("expAverages",expAverages);
		
		out.print("OK");

		logger.debug("end saveExperiments()");
				
	}
}
