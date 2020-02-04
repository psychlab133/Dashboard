<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

<%@ page import="javax.servlet.http.HttpSession"%>
<%@ page import="javax.servlet.http.HttpServletRequest"%>;

<%@ page import="java.util.ResourceBundle"%>
    
<%@ page import="org.apache.log4j.Logger"%>
<%@ page import="org.apache.log4j.Level"%>

<%@ page import="edu.wpi.fh2t.utils.*"%>

<% 
session = request.getSession();
//ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");
//Logger logger = (Logger) session.getAttribute("logger");
//logger.setLevel(Level.INFO);
//String ServerName = (String) request.getServerName();
//logger.info("servername=" + ServerName);
%>

<head>
<title>DATA Team Cluster Visualizations</title>
<style type="text/css">
body {
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0;
	margin-bottom: 0;
}
</style>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <script src="scripts/js/jquery.js" type="text/javascript"></script>
        <link rel="stylesheet" href="scripts/shared/fonts/fonts.css" />
        <script src="scripts/shared/libs/d3/d3.min.js"></script>
        <script src="scripts/shared/libs/geom.js/geom.min.js"></script>
        <script src="scripts/shared/libs/jquery/jquery-2.1.0.min.js"></script>
        <script src="scripts/shared/libs/bootstrap-3.3.4-dist/js/bootstrap.min.js"></script>
        <link rel="stylesheet" href="scripts/shared/css/navbar.css" />
        <link rel="stylesheet" href="scripts/shared/libs/bootstrap-3.3.4-dist/css/bootstrap.min.css" />
        <link rel="stylesheet" href="scripts/shared/libs/bootstrap-3.3.4-dist/css/no-btn-focus.css" />
        <script src="scripts/js/jquery-ui.min.js" type="text/javascript"></script>
	<script src="scripts/shared/libs/gmath/gmath-stable.min.js"></script>
</head>
<body style=background-color:white>

<div id="mainCanvas" style="position:relative; margin:auto; left:0; right:0; width:auto; background-color:white"></div>

<script>

var username = "Frank";

var X_COORD = 0;
var Y_COORD = 1;
var STATE = 2;
var ETIME = 3;
var HEIGHT = 4;
var BCOLOR = 5;
var FCOLOR = 6;
var ACTION = 7;
var METHOD = 8;

var eventH = 50;
var eventW = 300;
var eventL = 1;
var strEventH = eventH + "px";
var strEventW = eventW + "px";
var strEventL = eventL + "px";

var errorH = 25;
var errorW = 200;
var errorL = 50;
var strErrorH = errorH + "px";
var strErrorW = errorW + "px";
var strErrorL = errorL + "px";

var actionH = 25;
var actionW = 250;
var actionL = 25;
var strActionH = actionH + "px";
var strActionW = actionW + "px";
var strActionL = actionL + "px";

var rawData="";
var gmAPIData="";
var attemptstats;
var data = [];
var start_state = "";
var goal_state = "";

function loadData()
{
	alert("Hello");
	data = [];
	document.getElementById("mainCanvas").innerHTML="";

	var ycoord = 10;
	var elapsedTime = 0.0;
	var filename = "C:/WPI/Visualizer/" + username + "_events.csv";
	var loadedCSV= "http://localhost:8080/fh2tReportingWeb/" + username + "_events.csv";

	alert(loadedCSV);

	d3.csv(loadedCSV, function(allData) {
		alert("loaded");
	    allData.forEach(function(d, i) {
				alert("foreach");
				var actionText = ("" + d["action"]).trim();
				if (actionText == "start") {
					data.push([eventL, ycoord, d["expr_ascii"], d["elapsed"], eventH,  "white", 0, d["action"],d["method"]]);
					ycoord = ycoord + 15 + eventH;
					start_state = ("" + d["expr_ascii"]).trim();
					goal_state  = ("" + d["method"]).trim();
				}
				else if (actionText == "error") {
					data.push([errorL, ycoord, d["expr_ascii"], d["elapsed"], errorH,  "#F0E68C", 0, d["action"],d["method"]]);
					ycoord = ycoord + 15 + errorH;
				}
				else if (actionText == "reset") {
					data.push([errorL, ycoord, d["expr_ascii"], d["elapsed"], errorH,  "#d9534f", 0, d["action"],d["method"]]);
					ycoord = 10;
					eventL  += 325;
					errorL  += 325;
					actionL += 325; 

					data.push([eventL, ycoord, start_state,     d["elapsed"], eventH,  "white",   0, "start",    d["method"]]);
					ycoord = ycoord + 15 + eventH;
				}
				else {
					data.push([actionL, ycoord, "action", d["elapsed"], errorH,  "lightblue", 0, d["action"],d["method"]]);
					ycoord = ycoord + 15 + errorH;

					data.push([eventL, ycoord, d["expr_ascii"], d["elapsed"], eventH, "white", 0, "state",d["method"]]);
					ycoord = ycoord + 15 + eventH;	
				}		
	});
	init();	
	});
}

function init()
{
document.getElementById("mainCanvas").innerHTML="";
var previousState="";
var currentTime=0;
var timeInterval=20;

 var c10 = d3.scale.category10();
 var svg = d3.select("#mainCanvas")
   .append("svg")
   .attr("width", "950px")
   .attr("height", (data.length)*75+"px");

 var drag = d3.behavior.drag()
   .on("drag", function(d, i) {
     d[0] += d3.event.dx
     d[1] += d3.event.dy
     d3.select(this).attr("x", d[0]).attr("y", d[1]);
     d3.select(this).select("rect").attr("x", d[0]).attr("y", d[1]);
     d3.select("#dl_"+i).style("left", d[0]+"px").style("top", d[1]+"px");	 
	 
	 d3.selectAll(".link").each(function(l, li) {
       if (li == i) {
         d3.select(this).attr("x1", d[0]+eventH).attr("y1", d[1]);
       } else if (li+1 == i) {
         d3.select(this).attr("x2", d[0]+eventH).attr("y2", d[1]);
       }
     });
   });


	gmath.ui = gmath.ui || {};
   	data.forEach(function(d,i){
		elapsedTime=d[ETIME];;

	if (d[ACTION] == "error") {
		var div = document.createElement("div");
		div.id="dl_"+i;
		div.style.width = strErrorW;
		div.style.height = strErrorH;
		div.style.position="absolute";
		div.style.left= d[X_COORD];
		div.style.borderRadius="5px";
		div.style.top=d[Y_COORD]+"px";
		div.style.backgroundColor = d[BCOLOR];
		div.style.color = "black";
	//	div.innerHTML = "<span id='dlDisplay_"+i+"' style='width:" + strEventW + "'></span><span style='position: absolute; width:275px; left:0; top:0; margin-left: -290px; text-align: right'></span>";
		div.innerHTML = "<span style='position: absolute; width:100px; left:0; top:-36; margin-left: -40px; text-align: left'><br>" + d[ETIME] + "&nbspsecs</span><span style='position: absolute; width:300px; left:100; top:0; margin-left: -150px; text-align: left'> <p style=text-align:center;font-size:18px;>"  + d[METHOD] + "</p></span>";
	}
	else if (d[ACTION] == "reset") {
		var div = document.createElement("div");
		div.id="dl_"+i;
		div.style.width = strErrorW;
		div.style.height = strErrorH;
		div.style.position="absolute";
		div.style.left= d[X_COORD];
		div.style.borderRadius="5px";
		div.style.top=d[Y_COORD]+"px";
		div.style.backgroundColor = d[BCOLOR];
		div.style.color = "white";
		div.innerHTML = "<span style='position: absolute; width:100px; left:0; top:-36; margin-left: -40px; text-align: left'><br>" + d[ETIME] + "&nbspsecs</span><span style='position: absolute; width:300px; left:100; top:0; margin-left: -150px; text-align: left'> <p style=text-align:center;font-size:18px;>"  + d[METHOD] + "</p></span>";
	}
	else { 

		if (d[STATE] == "action") {
			var div = document.createElement("div");
			div.id="dl_"+i;
			div.style.width = strActionW;
			div.style.height = strActionH;
			div.style.position="absolute";
			div.style.left= d[X_COORD];
			div.style.borderRadius="5px";
			div.style.top=d[Y_COORD]+"px";
			div.style.backgroundColor = d[BCOLOR];
			div.style.color = "black";
			div.innerHTML = "<span style='position: absolute; width:100px; left:0; top:-36; margin-left: -17px; text-align: left'><br>" + d[ETIME] + "&nbspsecs</span><p style=text-align:center;font-size:18px;>" + d[ACTION] + "</p>";
		}                   
		else {
			var div = document.createElement("div");
			div.id="dl_"+i;
			div.style.width = strEventW;
			div.style.height = strEventH;
			div.style.position="absolute";
			div.style.left= d[X_COORD];
			div.style.borderRadius="5px";
			div.style.top=d[Y_COORD]+"px";
			if (d[STATE] == goal_state) {
				div.style.backgroundColor = "lightgreen";
			}
			else {
				div.style.backgroundColor = d[BCOLOR];
			}
			div.style.color = "black";
			div.innerHTML = "<span id='dlDisplay_"+i+"' style='width:" + strEventW + "'></span>";
		}
	}
	
	document.getElementById("mainCanvas").appendChild(div);
	
	gmath.ui.Pill = (function() {
		var GMPill = function() {
		this.loadSettings();
	}	
	
	GMPill.prototype.loadSettings = function() 
	{
		var svgm = d3.select('#dlDisplay_'+i).append('svg').style('margin-top', '5px').style('margin-left', '0px').style('width', eventW);
		var model = new gmath.AlgebraModel(((d[STATE].indexOf("ANSWERED ")!==-1)?d[STATE].replace("ANSWERED ",""):d[STATE]));
		var view = new gmath.AlgebraView(model, svgm, {interactive: false, "inactive_color": "black", "auto_resize_container":true, "font_size": 24, "normal_font":{"family":"Kalam","id":"_8a041c46eb608104"},"italic_font":{"family":"Kalam","id":"_8a041c46eb608104"}, pos: [135, 30]})
		view.init();
	}
	return GMPill;
})();
	var tempPill = new gmath.ui.Pill();
	});	
	setTimeout(function(){
		data.forEach(function(d,i)
		{
			if(i<data.length-1)
			{
				var translate=document.getElementById("dlDisplay_"+i).childNodes[0].childNodes[0].childNodes[3].getAttribute("transform");
				//document.getElementById("dlDisplay_"+i).childNodes[0].childNodes[0].innerHTML='<circle cx="'+(20+parseFloat(document.getElementById("dlDisplay_"+i).childNodes[0].childNodes[0].getBoundingClientRect().width)*parseFloat(0))+'" cy="'+(parseFloat(document.getElementById("dlDisplay_"+i).childNodes[0].childNodes[0].getBoundingClientRect().height)*parseFloat(d[6])-20)+'" r="15" fill="rgba(255,0,0,0.5)" transform=" '+translate+'"/>'+document.getElementById("dlDisplay_"+i).childNodes[0].childNodes[0].innerHTML;
			}
		});
	}, 1000);
	
}
$(document).ready(function () {
	alert("Ready to loaddata()");
	loadData();
  });

</script>
</body>
</html>
