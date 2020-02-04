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

public class getSelectionPanel extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public getSelectionPanel() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");

		logger.setLevel(Level.DEBUG);
		
		PrintWriter out = response.getWriter();

		logger.debug("getSelectionPanel servlet starting");				

		out.print("<div id=menus class='col-md-8 col-sm-12 col-xs-12v'>");
		out.print("  <div id='level1' class='col-md-5 col-sm-5 col-xs-12v'>");
		out.print("    <div class='col-5' id='level1Selection'></div>");
		out.print("  </div>");
		
		out.print("  <div id='level2' class='col-md-2 col-sm-6 col-xs-12v'>");
		out.print("    <div class='col-5' id='level2Selection'></div>");
		out.print("  </div>");
		
		out.print("  <div id='level3' class='col-md-2 col-sm-6 col-xs-12v'>");
		out.print("    <div class='col-5' id='level3Selection'></div>");
		out.print("  </div>");
		
		out.print("  <div id='level4' class='col-md-3 col-sm-6 col-xs-12v'>");
		out.print("    <div class='col-5' id='level4Selection'></div>");
		out.print("  </div>");
		out.print("</div>");


	}
}
