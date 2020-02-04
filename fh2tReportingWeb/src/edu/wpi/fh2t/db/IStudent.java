package edu.wpi.fh2t.db;

public interface IStudent {
	static final String self = "self";
	
	void setId(String id);
	String getId();
	void setName(String name);
	String getName();

}
