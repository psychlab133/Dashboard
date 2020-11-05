package edu.wpi.fh2t.servlets;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;

import java.io.File;

import java.io.PrintWriter;
import java.util.ResourceBundle;

public class getProblemTreeMap extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public getProblemTreeMap() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		PrintWriter out = response.getWriter();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");

		logger.setLevel(Level.DEBUG);
		
		logger.debug("getProblemTreeMap servlet starting");			

		String str = "FileNotFound";
		String problemId = "";
		if (request.getParameter("problemId") != null) {
			problemId = request.getParameter("problemId");			
		}
		if (problemId.length() == 1) {
			problemId = "00" + problemId;
		}
		else {
			if (problemId.length() == 2) { 
				problemId = "0" + problemId;
			}
		}
		
	    String relativePath = getServletContext().getRealPath("");

		String filePath = relativePath + "images\\problem_" + problemId + "_Treemap.png";
	    System.out.println(filePath);
		logger.debug(filePath);
		try {
			File f = new File(filePath);
			if(f.exists() && !f.isDirectory()) { 
				str = "treeMap";
			}
		}
		catch (Exception e) {
			logger.error(e.getMessage());
		}
		out.print(str);
		logger.debug("result is " + str);
		logger.debug("end getProblemTree()");
				
	}
}
