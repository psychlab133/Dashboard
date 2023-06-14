package edu.wpi.fh2t.servlets;

lol

import com.mysql.jdbc.Connection;
import com.mysql.jdbc.Statement;
import com.mysql.jdbc.PreparedStatement;

import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.ResourceBundle;

import edu.wpi.fh2t.utils.*;

public class approveUser extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public approveUser() {
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

		String strRoles="";
		if (request.getParameter("strRoles") != null) {
			strRoles= request.getParameter("strRoles");
		}
		
		
		String DBpwd = "";
		String DBemail = "";
		String DBusername = "";
		
		int DBid = 0;
	
		int DBrole = 0;
	
		String str = "";
		String idQuery = "select ID as ID, email as EMAIL, username as NAME, password as PWD from usernames where username = '" + username + "';";		

		
		String userroleQuery = "";		
		PreparedStatement userrolePstmt = null;
		
		Connection con = null;
		PreparedStatement pstmt = null;
		try {
			Class.forName((String) getServletContext().getInitParameter("rptdbClass"));
			con = (Connection) DriverManager.getConnection ((String) getServletContext().getInitParameter("rptdbUrl"),(String) getServletContext().getInitParameter("rptdbUser"),(String) getServletContext().getInitParameter("rptdbPwd"));
			PreparedStatement idPstmt = (PreparedStatement)con.prepareStatement(idQuery);
			ResultSet rs = idPstmt.executeQuery(idQuery);
			if (rs.next()) {
				DBpwd = rs.getString("PWD");
				DBusername = rs.getString("NAME");
				DBemail = rs.getString("EMAIL");
				int intUserID = rs.getInt(1);

				String userID = Integer.toString(intUserID);
			    String[] arrRoles = strRoles.split("~");
			    for (int i=0; i < (arrRoles.length - 1); i++) {			    	                 
				    userroleQuery = "INSERT INTO userrole (userID, roleID) values (\"" + userID + "\",\"" + arrRoles[i] + "\");";
				    logger.debug(userroleQuery);
				    userrolePstmt = (PreparedStatement)con.prepareStatement(userroleQuery);
				    userrolePstmt.execute(userroleQuery);
				    userrolePstmt.close();
				    userrolePstmt = null;
				}
				String updateQuery = "UPDATE usernames set role = \"1\" WHERE username = \"" + username + "\";";	
			    PreparedStatement updatePstmt = (PreparedStatement)con.prepareStatement(updateQuery);
				updatePstmt.execute(updateQuery);
				updatePstmt.close();
				DashboardEmail de = new DashboardEmail();
				de.sendmail(DBemail,DBpwd, "DASHBOARD ACCOUNT REQUEST APPROVED",
						"<p>Your request for a Researcher Dashboard account has been approved! Please use the following credentials to log into the Dashboard (<a href=\"http://fh2tresearch.com\">FH2T</a>)</p>\r\n" + 
						"\r\n" + 
						"<p><b>USERNAME: "+ DBusername +"<br>\r\n" + 
						"PASSWORD: "+ DBpwd +"</b></p>\r\n" + 
						"\r\n" + 
						"<p><b>Best,<br>\r\n" + 
						"The IES Dashboard Team</b></p>");

			}
			rs.close();
		    idPstmt.close();
			con.close();
		} //end try
		catch (ClassNotFoundException e1) {
			logger.error(e1.getMessage());
			logger.error(e1.fillInStackTrace());
			str = "Error!" + e1.getMessage();
		}
		catch(java.sql.SQLException e2) {
			logger.error(e2.getMessage());
			logger.error(e2.fillInStackTrace());
			str = "Error!" + e2.getMessage();
		}
		catch(Exception e) {
			logger.error(e.getMessage());
			logger.error(e.fillInStackTrace());
			str = "Error!" + e.getMessage();
		}
		if (str.length() == 0) {
			str = username + " was approved.";
			logger.debug(str);
		}
		out.print(str);
	}
}
