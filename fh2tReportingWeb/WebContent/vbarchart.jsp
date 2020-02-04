<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>

<%@ page import="javax.servlet.http.HttpSession"%>
<%@ page import="java.util.ResourceBundle"%>
    
<%@ page import="org.apache.log4j.Logger"%>
<%@ page import="org.apache.log4j.Level"%>

<%@ page import="edu.wpi.fh2t.utils.*"%>

<% 
session = request.getSession();
ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");
Logger logger = (Logger) session.getAttribute("logger");
logger.setLevel(Level.DEBUG);
Person currentUser = (Person) session.getAttribute("currentUser");

logger.debug("CurrentUser=" + currentUser.getName());

String graphs = request.getParameter("graphs");
if (graphs == null) {
	graphs = "1";
}
else {
	logger.debug("graphs = " + graphs);
}

String inLeftData = request.getParameter("ldata");
if (inLeftData == null) {
	logger.debug("inLeftData is null");	
}
else {
	logger.debug("inLeftData = " + inLeftData);
}

String inRightData = request.getParameter("rdata");
if (inRightData == null) {
	logger.debug("inRightData is null");	
}
else {
	logger.debug("inRightData = " + inRightData);
}
%>
   <!DOCTYPE html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><%= rb.getString("title")%></title>
  <link rel="stylesheet" href="css/bootstrap.min.css">
  <link rel="stylesheet" href="css/styles.css">
  <link href='https://fonts.googleapis.com/css?family=Oxygen:400,300,700' rel='stylesheet' type='text/css'>
  <link href='https://fonts.googleapis.com/css?family=Lora' rel='stylesheet' type='text/css'>
  <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.8.1/css/all.css"
    integrity="sha384-50oBUHEmvpQ+1lW4y57PTFmhCaXp0ML5d60M1M7uH2+nqUivzIebhndOJK28anvf" crossorigin="anonymous">

    <!-- jQuery (Bootstrap JS plugins depend on it) -->
    <script src="js/jquery-2.1.4.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/script.js"></script>  <script src="https://d3js.org/d3.v4.min.js"></script>
  <style>
    body { margin: 0; position: fixed; top: 0; right: 0; bottom: 0; left: 0; }
    svg { width: 100%; height: 100%; }

graph-header {
	padding 0 
}

#left-graph-container {
  border-radius: 25px;
  border: 2px solid black;
  padding: 20px; 
  width: 50%;
  height: 90%;
  background-color:white;  
}

#right-graph-container {
  border-radius: 25px;
  border: 2px solid black;
  padding: 20px; 
  width: 50%;
  height: 90%;
  background-color:white;  
}

#wide-graph-container {
  border-radius: 25px;
  border: 2px solid black;
  padding: 20px; 
  width: 100%;
  height: 90%;
  background-color:white;  
}


  </style>
</head>

<body>
	<div class="container">
	<div id="double-wide">
		<div class="row">
			<div class="col-md-1">		
			</div>
			<div class="col-md-4 text-center bg-primary text-white">
  				Completion by world
			</div>
			<div class="col-md-1">		
			</div>
			<div class="col-md-1">		
			</div>
			<div class="col-md-4 text-center bg-primary text-white">
  				Some other graphical representation   				
			</div>
			<div class="col-md-1">		
			</div>

		</div>		
		<div id="side-by-side-graph-row" class="row">
			<div id="left-graph-container" class="col-md-6">
  				<svg id="left-graph"></svg>
			</div>
			<div id="right-graph-container" class="col-md-6">
  				<svg id="right-graph"></svg>
			</div>
		</div>	
    </div>
	<div id="single-wide">
		<div class="row">
			<div class="col-md-4">		
			</div>
			<div class="col-md-4 text-center bg-primary text-white">
  				Comparison View
			</div>
			<div class="col-md-4">		
			</div>
		</div>		
		<div id="wide-graph-row class="row">
			<div id="wide-graph-container" class="col-md-12">
  				<svg id="wide-graph"></svg>
			</div>
		</div>
    </div>
    </div>
  <script>
    // options
    var margin = {"top": 20, "right": 10, "bottom": 80, "left": 30 }
    var width = 480;
    var height = 200;
    var rectWidth = 40;
      
    var strGraphs   = "<%=graphs%>";
    var graphs = Number(strGraphs);
	var inLeftData  = "<%=inLeftData%>";
	if (inLeftData.length == 1) {
		inLeftData = "";
	}
	var inRightData = "<%=inRightData%>";
	if (inRightData.length == 1) {
		inRightData = "";
	}


	var actions = [];
	var merge = false;
	if (graphs == 1) {
		if ((inLeftData.length > 0) && (inRightData.length > 0)){
			actions.push("doMerge");
			document.getElementById("double-wide").innerHTML = "";		
		}
		else {
			if (inLeftData.length > 0) {
				actions.push("doLeft");	
				document.getElementById("single-wide").innerHTML = "";		
				//document.getElementById("right-graph-container").innerHTML = "";		
			}
			else {
				actions.push("doRight");	
				document.getElementById("single-wide").innerHTML = "";		
				//document.getElementById("left-graph-container").innerHTML = "";		
			}
		}
	}
	else {
		graphs = 2;
		if (inLeftData.length > 0) {
			actions.push("doLeft");	
		}
		if (inRightData.length > 0) {
			actions.push("doRight");	
		}
		document.getElementById("single-wide").innerHTML = "";		

	}
	
	actions.forEach(doAction);
	
	
function doAction(action,i) {
	var act = "" + action;

	if (act == "doLeft") {
		doLeft();
	} else if (act == "doRight") {
		doRight();
	} else if (act == "doMerge") {
		doMerge();
	}
}	
	
	
function doMerge() {
	

    //alert("doMerge");
    var inLeftDataArr = inLeftData.split(",");
    var inRightDataArr = inRightData.split(",");

    var columns = inLeftDataArr.length;
	
	var wdata = [];
    for (var i=0; i < inLeftDataArr.length; i++) {
        var element = [];
		var element2 = [];
        element[0] = Number(inLeftDataArr[i]);
        if (element[0] > 15) {
        	element[1] = "green";
        }
        else if (element[0] > 12) {
        	element[1] = "yellow";
        }
        else if (element[0] > 9) {
        	element[1] = "orange";
        }
        else {
        	element[1] = "red";
        }
		wdata.push(element);
        element2[0] = Number(inRightDataArr[i]);
        element2[1] = "teal";
		wdata.push(element2);
    }
    // scales

    var xMax = (columns * 2) * rectWidth ;
    var xScale = d3.scaleLinear()
    	.domain([0, xMax])
    	.range([margin.left, width - margin.right]);

    
    var yMax = d3.max(wdata, function(d){return d[0]});
    var yScale = d3.scaleLinear()
    	.domain([0, yMax])
    	.range([height - margin.bottom, margin.top]);
     
    // svg element
    var svg = d3.select('#wide-graph');

    // bars 
    var rect = svg.selectAll('rect')
    	.data(wdata)
    	.enter().append('rect')
    	.attr('x', function(d, i){ 
        return xScale(i * rectWidth)})
    	.attr('y', function(d){
        return yScale(d[0])})
    	.attr('width', xScale(rectWidth) - margin.left)
    	.attr('height', function(d){
        return height - margin.bottom - yScale(d[0])})
			.attr('fill', function(d){
        return d[1]})
    	.attr('margin', 0);
    
    var x2Scale = d3.scaleLinear()
	.domain([0, columns])
	.range([margin.left, width - margin.right]);
    
    // axes
    var xAxis = d3.axisBottom()
    	.scale(x2Scale)
    	.tickFormat(d3.format('d'));
    var yAxis = d3.axisLeft()
    	.scale(yScale)
    	.tickFormat(d3.format('d'));
    
      svg.append('g')
      	.attr('transform', 'translate(' + [0, height - margin.bottom] + ')')
      	.call(xAxis);
      svg.append('g')
      	.attr('transform', 'translate(' + [margin.left, 0] + ')')
      	.call(yAxis);

}

function doLeft() {

    var inLeftDataArr = inLeftData.split(",");
    var columns = inLeftDataArr.length;
	
	var ldata = [];
    for (var i=0; i < inLeftDataArr.length; i++) {
        var element = [];
        element[0] = Number(inLeftDataArr[i]);
        if (element[0] > 15) {
        	element[1] = "green";
        }
        else if (element[0] > 12) {
        	element[1] = "yellow";
        }
        else if (element[0] > 9) {
        	element[1] = "orange";
        }
        else {
        	element[1] = "red";
        }
		ldata.push(element);
    }
 
    
    // scales

    var xMax = columns * rectWidth;
    var xScale = d3.scaleLinear()
    	.domain([0, xMax])
    	.range([margin.left, width - margin.right]);

    
    var yMax = d3.max(ldata, function(d){return d[0]});
    var yScale = d3.scaleLinear()
    	.domain([0, yMax])
    	.range([height - margin.bottom, margin.top]);
     
    // svg element
    var svg = d3.select('#left-graph');
		
    // bars 
    var rect = svg.selectAll('rect')
    	.data(ldata)
    	.enter().append('rect')
    	.attr('x', function(d, i){ 
        return xScale(i * rectWidth)})
    	.attr('y', function(d){
        return yScale(d[0])})
    	.attr('width', xScale(rectWidth) - margin.left)
    	.attr('height', function(d){
        return height - margin.bottom - yScale(d[0])})
			.attr('fill', function(d){
        return d[1]})
    	.attr('margin', 0);
    
    var x2Scale = d3.scaleLinear()
	.domain([0, columns])
	.range([margin.left, width - margin.right]);
    
    // axes
    var xAxis = d3.axisBottom()
    	.scale(x2Scale)
    	.tickFormat(d3.format('d'));
    var yAxis = d3.axisLeft()
    	.scale(yScale)
    	.tickFormat(d3.format('d'));
    
      svg.append('g')
      	.attr('transform', 'translate(' + [0, height - margin.bottom] + ')')
      	.call(xAxis);
      svg.append('g')
      	.attr('transform', 'translate(' + [margin.left, 0] + ')')
      	.call(yAxis);
}

function doRight() {

    var inRightDataArr = inRightData.split(",");
    var columns = inRightDataArr.length;
	
	var rdata = [];
    for (var i=0; i < inRightDataArr.length; i++) {
        var element = [];
        element[0] = Number(inRightDataArr[i]);
        if (element[0] > 15) {
        	element[1] = "green";
        }
        else if (element[0] > 12) {
        	element[1] = "yellow";
        }
        else if (element[0] > 9) {
        	element[1] = "orange";
        }
        else {
        	element[1] = "red";
        }
		rdata.push(element);
    }
 
    
    // scales

    var xMax = columns * rectWidth;
    var xScale = d3.scaleLinear()
    	.domain([0, xMax])
    	.range([margin.left, width - margin.right]);

    
    var yMax = d3.max(rdata, function(d){return d[0]});
    var yScale = d3.scaleLinear()
    	.domain([0, yMax])
    	.range([height - margin.bottom, margin.top]);
     
    // svg element
    var svg = d3.select('#right-graph');
		
    // bars 
    var rect = svg.selectAll('rect')
    	.data(rdata)
    	.enter().append('rect')
    	.attr('x', function(d, i){ 
        return xScale(i * rectWidth)})
    	.attr('y', function(d){
        return yScale(d[0])})
    	.attr('width', xScale(rectWidth) - margin.left)
    	.attr('height', function(d){
        return height - margin.bottom - yScale(d[0])})
			.attr('fill', function(d){
        return d[1]})
    	.attr('margin', 0);
    
    var x2Scale = d3.scaleLinear()
	.domain([0, columns])
	.range([margin.left, width - margin.right]);
    
    // axes
    var xAxis = d3.axisBottom()
    	.scale(x2Scale)
    	.tickFormat(d3.format('d'));
    var yAxis = d3.axisLeft()
    	.scale(yScale)
    	.tickFormat(d3.format('d'));
    
      svg.append('g')
      	.attr('transform', 'translate(' + [0, height - margin.bottom] + ')')
      	.call(xAxis);
      svg.append('g')
      	.attr('transform', 'translate(' + [margin.left, 0] + ')')
      	.call(yAxis);
}    

  </script>
</body>