package edu.wpi.fh2t.utils;


public interface IVGraphRequest {
	static final String self = "self";

	void setRealm(String realm);
	String getRealm();
	String dump();

}
