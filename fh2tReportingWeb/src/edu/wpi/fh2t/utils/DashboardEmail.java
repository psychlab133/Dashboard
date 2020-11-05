package edu.wpi.fh2t.utils;

import java.io.UnsupportedEncodingException;
import java.time.Year;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.Random;

import com.sun.mail.smtp.SMTPTransport;

import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
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
	    prop.put("mail.smtp.host", "smtp.gmail.com"); //optional, defined in SMTPTransport "mailsrv.cs.umass.edu"
	    prop.put("mail.smtp.auth", "true");
	    prop.put("mail.smtp.starttls.enable", "true");
	    prop.put("mail.smtp.port", "587"); // default port 25
	    Authenticator auth = new Authenticator() {
            public PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication("fh2tresearch@gmail.com", "erot1234");
            }
        };
	    Session session = Session.getInstance(prop, auth);

	    MimeMessage msg = new MimeMessage(session);
	    try {

			// from
	        msg.setFrom(new InternetAddress("fh2tresearch@gmail.com"));

			// to
	        msg.setRecipients(Message.RecipientType.TO,
	                InternetAddress.parse(emailAddr, false));

			// subject
	        msg.setSubject(subject);

			// content
	        msg.setText(content,"UTF-8","html" );

	        msg.setSentDate(new Date());

			/*// Get SMTPTransport
	        SMTPTransport t = (SMTPTransport) session.getTransport("smtps");

			// connect
	        t.connect("mailsrv.cs.umass.edu", "mathspring@cs.umass.edu", "m4thspr1ng!");

	        // send
	        t.sendMessage(msg, msg.getAllRecipients());

	        //System.out.println("Response: " + t.getLastServerResponse());

	        t.close();*/
	        
	        Transport.send(msg);
	        
	    } catch (MessagingException e) {
	        e.printStackTrace();
	    }
 
	} // end sendmail
	
	
	
} // end class


