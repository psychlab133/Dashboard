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

public class getExperiments extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public getExperiments() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		PrintWriter out = response.getWriter();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");

		logger.setLevel(Level.DEBUG);
		
		logger.debug("starting getExperiments( servlet");
		
		String test = "FS~wpi_ies_study_fall_19~IES FGA Fall 2019";
		String str = "";
		
//		out.print("<div class='row'><div class='col-4 selection-header'><h4>" + rb.getString("experiments") + "</h4></div></div><div class='row'><div class='col-4'>");	

		str += "<select id='experimentSelections' class='custom-select' size='5'  onchange=setExperiment();>";
		str += "<option style='background-color:white;' value='FS~wpi_ies_study_fall_19'>FGA Fall 2019</option>";
		str += "<option style='background-color:white;' value='WS~wpi_ies_study_fall_19'>IES WMA - Fall 2019</option>";
		str += "</select>";

		out.print(str);


		logger.debug(str);
		logger.debug("end getExperiments()");
				
	}
}
