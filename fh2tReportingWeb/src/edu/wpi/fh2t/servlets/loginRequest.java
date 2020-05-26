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

import edu.wpi.fh2t.utils.*;

public class loginRequest extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public loginRequest() {
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

		String pwd="";
		if (request.getParameter("pwd") != null) {
			pwd = request.getParameter("pwd");
		}
		
		String DBpwd = "";
		int DBuserid = 0;
		int DBrole = 0;
		String strRoles = "";
		String DBemail = "";
		int DBid = 0;

		String query = "select username as DBNAME, password as PWD, role as ROLE, email as EMAIL, ID from usernames where username = '" + username + "';";		
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
					DBrole = rs.getInt("ROLE");
					DBid = rs.getInt("ID");
					break;
				}
			}
			rs.close();

			String roleQuery = "select userrole.userID as UID, roles.rolename as RNAME from userrole JOIN roles on userrole.roleID = roles.ID where userrole.userID = " + DBid + ";";
			logger.debug(roleQuery);
			ResultSet role_rs = pstmt.executeQuery(roleQuery);
			boolean first = true;
			while (role_rs.next()) {
				if (!first) {
					strRoles += ",";
				}
				else {
					first = false;
				}
				strRoles += role_rs.getString("RNAME");
			}
			logger.debug(strRoles);
			role_rs.close();			
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
		if (pwd.trim().equals(DBpwd.trim())) {
			logger.debug("passwords match");
			Person current = new Person(DBuserid,username,DBemail,strRoles);
			logger.debug(current.dump());
				
			if (strRoles.length() == 0) {
				out.print("Error: " +rb.getString("no_roles"));
			}
			else {
				session.setAttribute("currentUser",current);
				session.setMaxInactiveInterval(30*60);
				if (current.getRoles().length > 1) {
					str += "<form> ";  
					str += "<div class='form-group' onChange=viewPageSelected()'><label>" + rb.getString("roles") + "</label>";
					for (int i = 0; i <current.getRoles().length; i++) {
						str += "<div class='custom-control custom-radio custom-control-inline'>";
						if (i == 0) {
							str += "<input type='radio' checked class='custom-control-input' id='" + current.getRole(i) + "' name='roleSelections' onclick='" + current.getRole(i) + "PageSelected()'>";
						}
						else {
							str += "<input type='radio' class='custom-control-input' id='" + current.getRole(i) + "' name='roleSelections' onclick='" + current.getRole(i) + "PageSelected()'>";
						}
						str += "<label class='custom-control-label' for='" +  current.getRole(i) + "'>" + current.getRole(i) + "</label>";
						str += "</div>";
					}
					str += "</div>";
					str += "</form> ";            
				}
				else {
					str = "defaultPage";
				}

				out.print(str);
				System.out.println(str);
			}
		}
		else {
			logger.debug("incorrect password: " + pwd + " " + DBpwd);
			out.print("Error: " + rb.getString("unknown_username_or_password"));
		}
	}
}
