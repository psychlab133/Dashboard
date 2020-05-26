package edu.wpi.fh2t.servlets;


import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;

import javax.servlet.http.HttpSession;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import java.util.ResourceBundle;
import java.io.PrintWriter;

public class downloadFile extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public downloadFile() {
		super();
	}
	
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		
		Logger logger = (Logger) session.getAttribute("logger");
		ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");

		logger.setLevel(Level.DEBUG);

		//PrintWriter out = response.getWriter();

	    String expId = (String) session.getAttribute("expId");
		
		String filePath = "";
		if (request.getParameter("filename") != null) {
			filePath = "C:\\WPI\\DataFiles\\" + "2020_0131_" + expId + "_" + request.getParameter("filename");
			logger.debug(filePath);
		}
		
		// reads input file from an absolute path
        try {
		    File downloadFile = new File(filePath);
		    FileInputStream inStream = new FileInputStream(downloadFile);
		     
		    // if you want to use a relative path to context root:
		    String relativePath = getServletContext().getRealPath("");
		    System.out.println("relativePath = " + relativePath);
		     
		    // obtains ServletContext
		    ServletContext context = getServletContext();
		     
		    // gets MIME type of the file
		    String mimeType = context.getMimeType(filePath);
		    if (mimeType == null) {        
		        // set to binary type if MIME mapping not found
		        mimeType = "application/octet-stream";
		    }
		    System.out.println("MIME type: " + mimeType);


			// modifies response
		    response.setContentType(mimeType);
		    response.setContentLength((int) downloadFile.length());
		     
		    // forces download
		    String headerKey = "Content-Disposition";
		    String headerValue = String.format("attachment; filename=\"%s\"", downloadFile.getName());
		    response.setHeader(headerKey, headerValue);
		     
		    // obtains response's output stream
		    OutputStream outStream = response.getOutputStream();
		     
		    byte[] buffer = new byte[4096];
		    int bytesRead = -1;
		     
		    while ((bytesRead = inStream.read(buffer)) != -1) {
		        outStream.write(buffer, 0, bytesRead);
		    }
		     
		    inStream.close();
		    outStream.close();     
        }
        catch (Exception e) {
        	logger.error(e.getMessage());
        	e.printStackTrace();
		    String headerKey = "Content-Disposition";
		    String headerValue = "ErrorMsg";
		    response.setHeader(headerKey, headerValue);

        	PrintWriter out = response.getWriter();
        	out.print("!ERROR! ");
        	out.print(e.getMessage());
        	
        }
		
	}
}
