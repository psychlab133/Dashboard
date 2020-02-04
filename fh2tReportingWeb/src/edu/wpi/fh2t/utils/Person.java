package edu.wpi.fh2t.utils;

public class Person implements IPerson{
	private int Id;
	private String Email;
	private String Name;
	private String[] Roles;
	private String currentRole;
	
	public Person (int Id, String name, String email, String[] roles) {
		// TODO Auto-generated constructor stub
		setId(Id);
		setName(name);
		setEmail(email);
		setRoles(roles);
	}
	
	public Person (int Id, String name, String email, String roles) {
		// TODO Auto-generated constructor stub
		setId(Id);
		setName(name);
		setEmail(email);
		setRoles(roles);
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
	 * @return the email
	 */
	public String getEmail() {
		return Email;
	}

	/**
	 * @param email the email to set
	 */
	public void setEmail(String email) {
		this.Email = email;
	}
	
	/**
	 * @return the roles
	 */
	public String[] getRoles() {
		return Roles;
	}

	/**
	 * @return the roles
	 */
	public String getRole(int i) {
		return Roles[i];
	}

	/**
	 * @param the roles to set
	 */
	public void setRoles(String[] roles) {
		
		this.Roles = roles;
	}

	/**
	 * @param the roles to set
	 */
	public void setRoles(String roles) {
		
		String t[] = roles.split(",");
		this.Roles = t;
	}

	/**
	 * @param the roles to set
	 */
	public void setCurrentRole(String role) {
		
		this.currentRole = role;
	}
	/**
	 * @return the currentRole
	 */
	public String getCurrentRole() {
		return currentRole;
	}

	
	/**
	 * @return the id
	 */
	public int getId() {
		return Id;
	}

	/**
	 * @param id the id to set
	 */
	public void setId(int id) {
		Id = id;
	}

	public String dump() {
		String line = "";
		line = String.valueOf(getId()) + "," + getEmail();
		
		line += "Roles: [";
		for (int i=0;i< Roles.length;i++) {
			line += Roles[i] + " ";
		}
		line += "]";
		return line;
	}

}
