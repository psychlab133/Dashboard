package edu.wpi.fh2t.utils;

import java.time.Year;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.Random;

import com.sun.mail.smtp.SMTPTransport;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Date;
import java.util.Properties;

public class DashboardEmail {

	
	public DashboardEmail () {
		super();
	}

	
	public void sendmail(String emailAddr, String password, String subject, String content) {
		
		
	    Properties prop = System.getProperties();
	    prop.put("mail.smtp.host", "mailsrv.cs.umass.edu"); //optional, defined in SMTPTransport
	    prop.put("mail.smtp.auth", "true");
	    prop.put("mail.smtp.port", "25"); // default port 25
	    
	    Session session = Session.getInstance(prop, null);

	    Message msg = new MimeMessage(session);
	    try {

			// from
	        msg.setFrom(new InternetAddress("DoNotReply@cs.umass.edu"));

			// to
	        msg.setRecipients(Message.RecipientType.TO,
	                InternetAddress.parse(emailAddr, false));

			// subject
	        msg.setSubject(subject);

			// content
	        msg.setText(password);

	        msg.setSentDate(new Date());

			// Get SMTPTransport
	        SMTPTransport t = (SMTPTransport) session.getTransport("smtps");

			// connect
	        t.connect("mailsrv.cs.umass.edu", "mathspring@cs.umass.edu", "m4thspr1ng!");

	        // send
	        t.sendMessage(msg, msg.getAllRecipients());

	        //System.out.println("Response: " + t.getLastServerResponse());

	        t.close();

	    } catch (MessagingException e) {
	        e.printStackTrace();
	    }
 
	} // end sendmail
	
	
	
} // end class


