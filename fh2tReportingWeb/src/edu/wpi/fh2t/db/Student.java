package edu.wpi.fh2t.db;

public class Student implements IStudent {
	private String id;
	private String Name;
	
	public Student (String name) {
		// TODO Auto-generated constructor stub
		setName(name);
		setId("");
	}
	
	public Student (String name,String id) {
		// TODO Auto-generated constructor stub
		setId(id);
		setName(name);
	}
	
	/**
	 * @return the name
	 */
	public String getName() {
		return Name;
	}

	/**
	 * @param name the Name to set
	 */
	public void setName(String name) {
		this.Name = name;
	}
	
	
	/**
	 * @return the id
	 */
	public String getId() {
		return id;
	}

	/**
	 * @param id the id to set
	 */
	public void setId(String id) {
		this.id = id;
	}


}
