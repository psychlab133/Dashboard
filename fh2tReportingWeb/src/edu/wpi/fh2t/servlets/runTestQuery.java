package edu.wpi.fh2t.servlets;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import com.mysql.jdbc.Connection;
import com.mysql.jdbc.Statement;
import com.mysql.jdbc.PreparedStatement;

import java.io.PrintWriter;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.ResourceBundle;


public class runTestQuery extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected static String dbUrl;
	protected static String dbClass;

	public runTestQuery() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");

		PrintWriter out = response.getWriter();

		String testQuery = request.getParameter("testQuery");

		logger.debug("runTestQuery: " + testQuery);			

		out.print("<div class='table-responsive-sm'><table class='table table-bordered table-hover'>");

		String str = "";
		
//		System.out.println("query=" + testQuery);
		Connection con = null;
		try {
			Class.forName((String) getServletContext().getInitParameter("dbClass"));
			con = (Connection) DriverManager.getConnection ((String) getServletContext().getInitParameter("dbUrl"),(String) getServletContext().getInitParameter("dbUser"),(String) getServletContext().getInitParameter("dbPwd"));
			PreparedStatement pstmt = (PreparedStatement)con.prepareStatement(testQuery);
			ResultSet rs = pstmt.executeQuery(testQuery);
			boolean headerInserted = false;
			
			while (rs.next()) {
				ResultSetMetaData metaData = rs.getMetaData();
				int fieldCount = metaData.getColumnCount(); //number of column
				//System.out.println("fieldCount=" + fieldCount);
				if (!headerInserted) {
					str += "<thead></tr>";
					for (int i=1;i <= fieldCount;i++) {
						str += "<th>";
						str += metaData.getColumnLabel(i);
						str += "</th>";
					}
					str += "</tr></thead>";
					//System.out.println(str);
					headerInserted = true;
				}
				
				str += "<tr><tbody>";
				for (int i=1;i <= fieldCount;i++) {
					str += "<td>";
					int t = metaData.getColumnType(i);
					//System.out.println("columnType=" + t);
					if (t == 4) {
						str += rs.getInt(metaData.getColumnLabel(i));
					}
					else {
						str += rs.getString(metaData.getColumnLabel(i));
					}
					str += "</td>";
					//System.out.println(str);
				}
				str += "</tr></tbody>";
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
		finally {
			try {
				con.close();
			}
			catch(java.sql.SQLException e) {
				logger.error(e.getMessage());
				logger.error(e.fillInStackTrace());
			}			
		}

		//System.out.println(str);
		out.print(str);
		//out.print("<div class='form-group row playerlistbuttons'><div class='offset-sm-2 col-sm-2 pull-left'><button name='Close' type='close' class='btn btn-primary' onclick='window.close()'>Done</button></div></div></div> <!-- container-->");
		out.print("</table></div>");

	}
}
