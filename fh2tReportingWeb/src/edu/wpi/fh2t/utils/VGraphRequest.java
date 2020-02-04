package edu.wpi.fh2t.utils;

public class VGraphRequest implements IVGraphRequest{
	private String realm;
	private int graphs;
	private String[] data;
	private String title;
	private String xDesc;
	private String yDesc;
	

	
	public VGraphRequest () {
	}
	
	/**
	 * @return the realm
	 */
	public String getRealm() {
		return realm;
	}

	/**
	 * @param name the realm to set
	 */
	public void setRealm(String realm) {
		this.realm = realm;
	}
	


	/**
	 * @return the number of graphs
	 */
	public int getGraphs() {
		return graphs;
	}

	/**
	 * @param set the number of graphs to display
	 */
	public void setGraphs(int graphs) {
		this.graphs = graphs;
	}


	public String dump() {
		String line = "";
		return line;
	}

	/**
	 * @return the title
	 */
	public String getTitle() {
		return title;
	}

	/**
	 * @param text the title to set
	 */
	public void setTitle(String title) {
		this.title = title;
	}
	
	/**
	 * @return the graph data points
	 */
	public String getData(int index) {
		return data[index];
	}

	/**
	 * @param name the graph data points to set
	 */
	public void setData(String data, int index) {
		this.data[index] = data;
	}
	
	/**
	 * @return the x axis descriptor
	 */
	public String getxDesc() {
		return xDesc;
	}

	/**
	 * @param the y axis descriptor
	 */
	public void setxDesc(String xDesc) {
		this.xDesc = xDesc;
	}
	
	/**
	 * @return the y axis descriptor
	 */
	public String getyDesc() {
		return yDesc;
	}

	/**
	 * @param the y axis descriptor
	 */
	public void setyDesc(String yDesk) {
		this.yDesc = yDesc;
	}
	

}
