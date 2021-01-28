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
import java.util.Random;

import edu.wpi.fh2t.utils.*;

public class sendPassword extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public sendPassword() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,			
		HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");
		
		logger.setLevel(Level.DEBUG);

		PrintWriter out = response.getWriter();

		String username = "";
		if (request.getParameter("username") != null) {
			username = request.getParameter("username");
		}

	
		String DBpwd = "";
		int DBuserid = 0;
		String strRoles = "";
		String DBemail = "";
		int DBid = 0;

		String query = "select username as DBNAME, password as PWD, email as EMAIL, ID from usernames where username = '" + username + "';";		
		logger.debug("query=" + query);
		Connection con = null;
		try {
			Class.forName((String) getServletContext().getInitParameter("rptdbClass"));
			con = (Connection) DriverManager.getConnection ((String) getServletContext().getInitParameter("rptdbUrl"),(String) getServletContext().getInitParameter("rptdbUser"),(String) getServletContext().getInitParameter("rptdbPwd"));
			PreparedStatement pstmt = (PreparedStatement)con.prepareStatement(query);
			ResultSet rs = pstmt.executeQuery(query);
			while (rs.next()) {
				if (username.equals(rs.getString("DBNAME"))) {
					logger.debug(username + " logging in");
					DBpwd = rs.getString("PWD");
					DBuserid = rs.getInt("ID");
					DBemail = rs.getString("EMAIL");
					DBid = rs.getInt("ID");
					break;
				}
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
		
		String str = "";
		
        Random rand = new Random();
        int x = rand.nextInt(99999);
        String symbols = "!#$%";
        int mod = x % 3;
        String pw = username.substring(0,2) + Integer.toString(x) + symbols.substring(mod,mod+1);

		DashboardEmail de = new DashboardEmail();
		//de.sendmail(DBemail,DBpwd, "Your IES Dashboard","Your IES Dashboard password is " + DBpwd);
		de.sendmail(DBemail, DBpwd, "Your From Here to There Researcher Dashboard password",
				"<p>You recently requested to reset your password for the From Here to There (<a href=\"http://fh2tresearch.com\">FH2T</a>) research dashboard account. Please find your attached password below. <b>Thanks!</b></p>\r\n" + 
				"<b>Password:</b>" + DBpwd +
				"\r\n" + 
				"<p><b>Best,<br>\r\n" + 
				"The IES Dashboard Team</b></p>");
		str = "We have sent your password. Please check your email.";
		out.print(str);
	}
}
