package edu.wpi.fh2t.utils;

public interface IPerson {
	static final String self = "self";
	
	void setId(int Id);
	int getId();
	void setName(String name);
	String getName();
	void setEmail(String email);
	String getEmail();
	void setRoles(String roles);
	void setRoles(String[] roles);
	String[] getRoles();
	String getRole(int i);
	void setCurrentRole(String role);
	String getCurrentRole();
	String dump();

}
