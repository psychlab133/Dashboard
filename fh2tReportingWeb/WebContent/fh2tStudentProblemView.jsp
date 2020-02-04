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
logger.setLevel(Level.INFO);
Person currentUser = (Person) session.getAttribute("currentUser");
currentUser.setCurrentRole("Researcher");

//logger.setLevel(Level.DEBUG);
%>
    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

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
    <script src="js/script.js"></script>
    
<% 
if (logger.isDebugEnabled()) {
%>
<script>
	function debugAlert(msg) {
		alert(msg);
	}
</script>
<%	
}
else {
%>
<script>
function debugAlert(msg) {
		var amsg = msg;
	}
</script>	
<%
}
%>    
    <script>
    
	var currentTableNbr = 0;
    var currentLevel = "";
    	

    function Create2DArray(rows) {
    	var arr = [];

    	for (var i=0;i<rows;i++) {
    	   arr[i] = [];
    	}
 		return arr;
    }
    
    var resultsQuery = "";
    
    const STUDENTS = 1;
    const WORLDS   = 2;
    const PROBLEMS = 3;
    const ATTEMPTS = 4;
    
    const MAX_TABLES = 4;
    
    var levelTableNbr = [0,0,0,0,0];
    //var tableNames = ["", "usernames", "worlds", "problems","attempts"];
    //var tableColors = ["", "Teal", "DarkSeaGreen", "Coral","Orange"];
      
    var selectedColumnsArray = Create2DArray(5);
    var selectedOrderArray = Create2DArray(5);
    var selectedGroupArray = Create2DArray(5);

    var tables = [
    	{"name":"","color":"","keyColumn":""},
    	{"name":"usernames","color":"Teal","keyColumn":"usernames.ID"},
    	{"name":"worlds","color":"DarkSeaGreen","keyColumn":"worlds.ID"},
    	{"name":"problems","color":"Coral","keyColumn":"problems.ID"},
    	{"name":"attempts","color":"Orange","keyColumn":"attempts.ID"}
    
    ];
    
   
    var dbkeyPairs = [
    	{"keyname":"usernames_attempts","primary":"usernames.ID","secondary":"attempts.userID"},
    	{"keyname":"worlds_problems","sort":"worlds.ID","primary":"worlds.ID","secondary":"problems.worldID"},
    	{"keyname":"problems_worlds","sort":"problems.ID","secondary":"problems.worldID","primary":"worlds.ID"}
    ];
    
    // 3 TABLE JOIN
    // SORT BY - first table column
    // JOIN make primary comparators the column from the table you are JOINing from
    var dbkeyTriples = [
    	{"keyname":"usernames_attempts_problems","sort":"usernames.username","primary1":"attempts.userID","secondary1":"usernames.ID","primary2":"problems.ID","secondary2":"attempts.problemID"}
    ];

    function clearColumnsArray(nbr) {
    	for (i=0;i<25;i++) {
    		selectedColumnsArray[nbr][i] = "";
    	}
    	
    }
    function clearOrderArray(nbr) {
    	for (i=0;i<25;i++) {
    		selectedOrderArray[nbr][i] = "";
    	}
    	
    }
    function clearGroupArray(nbr) {
    	for (i=0;i<25;i++) {
    		selectedGroupArray[nbr][i] = "";
    	}
    	
    }

    for (j=1;j<5;j++) {
    	clearColumnsArray(j);
    	clearOrderArray(j);
    	clearGroupArray(j);
    }
    
	</script>

<script>

    function save() {
      //alert("Save");
    }
   
    function getNextLevel(tableNbr) {
    	var levelName = "";
    	
    	var i=1;
		for (i = 1; i <= MAX_TABLES; i++) {
			if (tableNbr == levelTableNbr[i]) {
				alert("Table already selected");
				return "";
			}
		}

    	if (document.getElementById("level1Selection").innerHTML == "") {
    		levelTableNbr[1] = tableNbr;
    		levelName = "level1Selection";
    	}
    	else if (document.getElementById("level2Selection").innerHTML == "") {
    		levelTableNbr[2] = tableNbr;
    		levelName = "level2Selection";
    	}
    	else if (document.getElementById("level3Selection").innerHTML == "") {
    		levelTableNbr[3] = tableNbr;
    		levelName = "level3Selection";
    	}
    	else if (document.getElementById("level4Selection").innerHTML == "") {
    		levelTableNbr[4] = tableNbr;
    		levelName = "level4Selection";
    	}
    	//alert("level1table=" + levelTableNbr[1]);
    	//alert("level2table=" + levelTableNbr[2]);
    	//alert("level3table=" + levelTableNbr[3]);
		if (levelName.length == 0) {
			alert("Too many tables selected");
		}
    	return levelName;
    }

    function getLevelNbr(levelSelection) {
    	var x = 0;
    	if (levelSelection == "level1Selection") {
    		x = 1;
    	}
    	if (levelSelection == "level2Selection") {
    		x = 2;
    	}
    	if (levelSelection == "level3Selection") {
    		x = 3;
    	}
    	if (levelSelection == "level4Selection") {
    		x = 4;
    	}
    	return x;
    }

    function getSelectorMask(ExperimentID) {
    	
    	role = "Researcher";
    	ExperimentAbbrev = "FS";
    	var id = "FS0101-101";

    	var mask = "";
    	if (role == "Researcher") {
    		mask = ExperimentAbbrev + "____-___";
    	}
    	else if (role == "Teacher") {
    		mask = ExperimentAbbrev + school + teacher + "-___";			
    	}
		var experimentID = "FS";
    	var school = "__";
    	var teacher = "__";
    	var classroom = "_";
    	var student = "__";
    	
    	mask = "FS" + school + teacher + "-" + classroom + student;
    	
    	return mask;
    }
    
    
    function getStudents() {
      var xmlhttp;
      
      //var currentLevel = "";
      if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
        xmlhttp = new XMLHttpRequest();
      }
      else {// code for IE6, IE5
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
      }
      xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
          document.getElementById(currentLevel).innerHTML = xmlhttp.responseText;
        }
      };
      
      currentTableNbr = STUDENTS;
      currentLevel = getNextLevel(currentTableNbr);
      if (currentLevel.length > 0) {
      	var cmd = "GetStudents?tablecolor=" + tables[currentTableNbr].color + "\&level=" + getLevelNbr(currentLevel);
      	xmlhttp.open("GET", cmd, true);
      	xmlhttp.send();
      }
      
    }

    function resetStudents(){
    	$('select#usernamesSelections option').removeAttr("selected");
    }
    
    function getWorlds() {
        var xmlhttp;
        
        currentLevel = "";
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
            document.getElementById(currentLevel).innerHTML = xmlhttp.responseText;
          }
        };
        
        currentTableNbr = WORLDS;
        currentLevel = getNextLevel(currentTableNbr);
        if (currentLevel.length > 0) {
        	var cmd = "GetWorlds?tablecolor=" + tables[currentTableNbr].color + "\&level=" + getLevelNbr(currentLevel);
//        	alert(cmd);
        	xmlhttp.open("GET", cmd, true);
        	xmlhttp.send();
        }
        
      }

    function resetWorlds(){
    	$('select#worldsSelections option').removeAttr("selected");
    }
    
    function getProblems() {
        var xmlhttp;
        //alert("getProblems");
        
        currentLevel = "";
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
            document.getElementById(currentLevel).innerHTML = xmlhttp.responseText;
          }
        };
        
        currentTableNbr = PROBLEMS;
        currentLevel = getNextLevel(currentTableNbr);
        if (currentLevel.length > 0) {
        	var cmd = "GetProblems?tablecolor=" + tables[currentTableNbr].color + "\&level=" + getLevelNbr(currentLevel);
        	//alert(cmd);
        	xmlhttp.open("GET", cmd, true);
        	xmlhttp.send();
        }
        
      }

    function resetProblems(){
    	$('select#problemsSelections option').removeAttr("selected");
    }
    
    
    function getAttempts() {
        var xmlhttp;
        //alert("getAttempts");
        
        currentLevel = "";
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
            document.getElementById(currentLevel).innerHTML = xmlhttp.responseText;
          }
        };
        
        currentTableNbr = ATTEMPTS;
        currentLevel = getNextLevel(currentTableNbr);
        if (currentLevel.length > 0) {
        	var cmd = "GetAttempts?tablecolor=" + tables[currentTableNbr].color + "\&level=" + getLevelNbr(currentLevel);
        	//alert(cmd);
		    alert("This may take a few moments due to large number of attempts");
        	xmlhttp.open("GET", cmd, true);
        	xmlhttp.send();
        }
        
      }

    function resetAttempts(){
    	$('select#attemptsSelections option').removeAttr("selected");
    }
   
    
    function getColumns(colNbr) {
        var xmlhttp;
      		
        currentTableNbr = levelTableNbr[colNbr];
        
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
            //alert("ready");
            var raw = xmlhttp.responseText;
            var ins = tables[currentTableNbr].name + "ColumnSelections"
            response  = raw.replace("Options", ins);
            document.getElementById("columnSelect").innerHTML = response;
            ins = tables[currentTableNbr].name + "OrderSelections"
            response  = raw.replace("Options", ins);
            document.getElementById("columnOrder").innerHTML = response;
            ins = tables[currentTableNbr].name + "GroupSelections"
            response  = raw.replace("Options", ins);
            document.getElementById("columnGroup").innerHTML = response;
            $('#columnsModal').modal('toggle');
          }
        };
        var cmd = "GetColumns?tablename=" + tables[currentTableNbr].name + "\&tablecolor=" + tables[currentTableNbr].color;
        xmlhttp.open("GET", cmd, true);
        xmlhttp.send();
      }

	function saveSelectedColumns() {

		var level = getLevelNbr(currentLevel);	
        currentTableNbr = levelTableNbr[level];
        debugAlert("currentTableNbr=" + currentTableNbr);
		var selectName = tables[currentTableNbr].name + "ColumnSelections";
		debugAlert(selectName);
		var x = document.getElementById(selectName).options.length;

		clearColumnsArray(currentTableNbr);
		
		var first = true;
		for (i = 0; i < x; i++) {
			//debugAlert("i=" + i + document.getElementById(selectName).options[i].text)
			if (document.getElementById(selectName).options[i].selected == true) {
				selectedColumnsArray[currentTableNbr][i] = document.getElementById(selectName).options[i].text;
				debugAlert(selectedColumnsArray[currentTableNbr][i]);
			}
		}
	}
	
	function saveOrderColumns() {

		var level = getLevelNbr(currentLevel);	
        currentTableNbr = levelTableNbr[level];
        debugAlert("currentTableNbr=" + currentTableNbr);
		var orderName = tables[currentTableNbr].name + "OrderSelections";
		debugAlert(orderName);
		var x = document.getElementById(orderName).options.length;

		clearOrderArray(currentTableNbr);
		
		var first = true;
		var j=0;
		for (i = 0; i < x; i++) {
			//debugAlert("i=" + i + document.getElementById(orderName).options[i].text)
			if (document.getElementById(orderName).options[i].selected == true) {
				selectedOrderArray[currentTableNbr][j] = document.getElementById(orderName).options[i].text;
				debugAlert(selectedOrderArray[currentTableNbr][j]);
				j = j + 1;
			}
		}
	}

	function saveGroupColumns() {
		
		var level = getLevelNbr(currentLevel);	
        currentTableNbr = levelTableNbr[level];
		var groupName = tables[currentTableNbr].name + "GroupSelections";
		var x = document.getElementById(groupName).options.length;

		clearGroupArray(currentTableNbr);
		
		var first = true;
		var j=0;
		for (i = 0; i < x; i++) {
			if (document.getElementById(groupName).options[i].selected == true) {
				selectedGroupArray[currentTableNbr][j] = document.getElementById(groupName).options[i].text;
				debugAlert(selectedGroupArray[currentTableNbr][j]);
				j = j + 1;
			}
		}
	}

	function clearWorkArea() {
		
    	var i=1;
    	var levelName = "";
		for (i = 1; i <= MAX_TABLES; i++) {
			levelTableNbr[i] = 0;
			levelName = "level" + i + "Selection";
			document.getElementById(levelName).innerHTML = "";
			clearColumnsArray(i);
			clearOrderArray(i);
			clearGroupArray(i);
		}
		document.getElementById("currentQuery").innerHTML = "";
		document.getElementById("resultsQuery").innerHTML = "";
		document.getElementById("resultsView").innerHTML = "";

	}
</script>
<script>

	function buildQuery() {
		

		var tableCount = 0;
    	var i=1;
		for (i = 1; i <= MAX_TABLES; i++) {
			if (levelTableNbr[i] > 0) {
				tableCount++;
				//alert("tableCount=" + tableCount);
			}
		}
		if (tableCount == 1) {
			buildSingleTableQuery(levelTableNbr[1]);
		}
		else if (tableCount == 2) {
			buildTwoTableQuery();
		}
		else if (tableCount == 3) {
			buildThreeTableQuery();
		}

	}
	function buildSingleTableQuery(tableNbr) {
	// Gather table choices
	// construct query string
	// send get request
	
	var selectName = tables[tableNbr].name + "Selections"

	

	var first=true
	var selectClause = "*";
	

	for(i=0; i<25; i++){
		if (selectedColumnsArray[tableNbr][i] == "" ) {
			
		}
		else {
			if (first == false) {
				selectClause += ",";
			}
			else {
				first = false;
				selectClause = "";
			}		
			selectClause += selectedColumnsArray[tableNbr][i];
		}
	}
	debugAlert("selectClause=" + selectClause);
	
	var whereClause = "";
	
	var x = document.getElementById(selectName).options.length;
	first = true;

	for (i = 0; i < x; i++) {
		if (document.getElementById(selectName).options[i].selected == true) {
			if (first == false){
				whereClause += " OR ";
			}
			else {
				first = false;
				whereClause += " WHERE ";
			}
			whereClause += "ID = " + document.getElementById(selectName).options[i].value;			
		}
	}
	debugAlert("final whereClause=" + whereClause);

	var groupClause = "";

	var x = selectedGroupArray[tableNbr].length;
	if (x > 0) {
		first = true;
		for (i = 0; i < x; i++) {
			var temp = selectedGroupArray[tableNbr][i];
			if (temp.length > 0) {
				if (first == false){
					groupClause += ",";
				}
				else {
					first = false;
					groupClause += " GROUP BY ";
					groupClause += tables[tableNbr].name + "." + temp;
				}
			}
			else {
				break;
			}
			debugAlert(groupClause);
		}
	}

	var orderClause = "";

	var x = selectedOrderArray[tableNbr].length;
	if (x == 0) {
		orderClause += tables[tableNbr].keyColumn; 
		debugAlert(orderClause);
	}
	else {
		for (i = 0; i < x; i++) {
			var temp = selectedOrderArray[tableNbr][i];
			if (temp.length > 0) {
				if (orderClause.length > 0) {
					orderClause += ",";
				}
				else {
					orderClause = " ORDER BY ";
				}
				orderClause += temp;			
				debugAlert(orderClause);
			}
			else {
				break;
			}
		}
	}

	
	var queryString = "SELECT " + selectClause + " FROM " + tables[tableNbr].name + whereClause + groupClause + orderClause + ";";

	debugAlert(queryString);
	
	document.getElementById("currentQuery").innerHTML = queryString;
	document.getElementById("resultsQuery").innerHTML = queryString;
}

	function buildTwoTableQuery() {
		// Gather table choices
		// construct query string
		// send get request
		var level1TableNbr = levelTableNbr[1];
		var level2TableNbr = levelTableNbr[2];
		
		var selectName1 = tables[level1TableNbr].name + "Selections"

		debugAlert("level1TableNbr=" + level1TableNbr);

		var first=true;
		var selectClause = "";
		for(i=0; i<25; i++){
			if (selectedColumnsArray[level1TableNbr][i] == "" ) {
				
			}
			else {
				if (selectClause.length > 0) {
					selectClause += ",";
				}
				selectClause += tables[level1TableNbr].name;
				selectClause += ".";
				selectClause += selectedColumnsArray[level1TableNbr][i];
			}
		}
		debugAlert(selectClause);

		selectName2 = tables[level2TableNbr].name + "Selections"
		for(i=0; i<25; i++){
			if (selectedColumnsArray[level2TableNbr][i] == "" ) {
				
			}
			else {
				if (selectClause.length > 0) {
					selectClause += ",";
				}
				selectClause += tables[level2TableNbr].name;
				selectClause += ".";
				selectClause += selectedColumnsArray[level2TableNbr][i];
			}
		}		
		if (selectClause.length == 0) {
			selectClause = "*"
		}
		debugAlert(selectClause);
		
		var whereClause = "";	
		var x = document.getElementById(selectName1).options.length;
		first = true;
		for (i = 0; i < x; i++) {
			if (document.getElementById(selectName1).options[i].selected == true) {
				if (first == false){
					whereClause += " OR ";
				}
				else {
					first = false;
					whereClause += " WHERE ";
				}
				whereClause += tables[level1TableNbr].name;
				whereClause += ".";
				whereClause += "ID = " + document.getElementById(selectName1).options[i].value;			
			}
		}
		debugAlert(whereClause);

		var onClause = "";
		var orderClause = "";
		
		var primary = "";
		var secondary = "";
		var searchPair = tables[level1TableNbr].name + "_"+ tables[level2TableNbr].name;
		alert("searchPair=" + searchPair);
		for(i=0;i<dbkeyPairs.length;i++) {
			if (dbkeyPairs[i].keyname === searchPair) {
				alert("keyname=" + dbkeyPairs[i].keyname);
				primary = dbkeyPairs[i].primary;
				secondary = dbkeyPairs[i].secondary;
				onClause = " ON " + primary + " = " + secondary;	
				//orderClause = " ORDER BY " + dbkeyPairs[i].sort;
				break;
			}
		}
		debugAlert(onClause);	
		
		var orderClause = "";

		var x = selectedOrderArray[level1TableNbr].length;
		if (x == 0) {
			orderClause += tables[level1TableNbr].keyColumn; 
			debugAlert(orderClause);
		}
		else {
			for (i = 0; i < x; i++) {
				var temp = selectedOrderArray[level1TableNbr][i];
				if (temp.length > 0) {
					if (orderClause.length > 0) {
						orderClause += ",";
					}
					else {
						orderClause = " ORDER BY ";
					}
					orderClause += temp;			
					debugAlert(orderClause);
				}
				else {
					break;
				}
			}
		}

		var x = selectedOrderArray[level2TableNbr].length;
		if (x == 0) {
			orderClause += tables[level2TableNbr].keyColumn; 
			debugAlert(orderClause);
		}
		else {
			for (i = 0; i < x; i++) {
				var temp = selectedOrderArray[level2TableNbr][i];
				if (temp.length > 0) {
					if (orderClause.length > 0){
						orderClause += ",";
					}
					else {
						orderClause = " ORDER BY ";
					}
					orderClause += temp;			
					debugAlert(orderClause);
				}
				else {
					break;
				}
			}
		}


		
		
		debugAlert(orderClause);
		
		var queryString = "SELECT " + selectClause + " FROM " + tables[level1TableNbr].name + " JOIN " + tables[level2TableNbr].name + onClause + whereClause + orderClause + ";";
		debugAlert(queryString);

		document.getElementById("currentQuery").innerHTML = queryString;
		document.getElementById("resultsQuery").innerHTML = queryString;
	}

	function buildThreeTableQuery() {
		// Gather table choices
		// construct query string
		// send get request
		var level1TableNbr = levelTableNbr[1];
		var level2TableNbr = levelTableNbr[2];
		var level3TableNbr = levelTableNbr[3];
		
		var selectName1 = tables[level1TableNbr].name + "Selections"

		alert("level1TableNbr=" + level1TableNbr);

		var first=true;
		var selectClause = "*";
		for(i=0; i<25; i++){
			if (selectedColumnsArray[level1TableNbr][i] == "" ) {
				
			}
			else {
				if (first == false) {
					selectClause += ",";
				}
				else {
					first = false;
					selectClause = "";
				}
				selectClause += tables[level1TableNbr].name;
				selectClause += ".";
				selectClause += selectedColumnsArray[level1TableNbr][i];
			}
		}
		alert(selectClause);

		selectName2 = tables[level2TableNbr].name + "Selections"
		first=true;
		for(i=0; i<25; i++){
			if (selectedColumnsArray[level2TableNbr][i] == "" ) {
				
			}
			else {
				if (first == false) {
					selectClause += ",";
				}
				else {
					first = false;
					selectClause += ",";
				}		
				selectClause += tables[level2TableNbr].name;
				selectClause += ".";
				selectClause += selectedColumnsArray[level2TableNbr][i];
			}
		}		
		alert(selectClause);
		
		selectName3 = tables[level3TableNbr].name + "Selections"
		first=true;
		for(i=0; i<25; i++){
			if (selectedColumnsArray[level3TableNbr][i] == "" ) {
				
			}
			else {
				if (first == false) {
					selectClause += ",";
				}
				else {
					first = false;
					selectClause += ",";
				}		
				selectClause += tables[level3TableNbr].name;
				selectClause += ".";
				selectClause += selectedColumnsArray[level3TableNbr][i];
			}
		}		
		alert(selectClause);
		
		var whereClause = "";	
		var x = document.getElementById(selectName1).options.length;
		first = true;
		for (i = 0; i < x; i++) {
			if (document.getElementById(selectName1).options[i].selected == true) {
				if (first == false){
					whereClause += " OR ";
				}
				else {
					first = false;
					whereClause += " WHERE ";
				}
				whereClause += tables[level1TableNbr].name;
				whereClause += ".";
				whereClause += "ID = " + document.getElementById(selectName1).options[i].value;			
			}
		}
		alert(whereClause);

		
		var onClause1 = "";
		var onClause2 = "";
		var primary1 = "";
		var primary2 = "";
		var secondary1 = "";
		var secondary2 = "";
		var orderClause = "";

		for(i=0;i<dbkeyTriples.length;i++) {
			//var searchTriple = tables[level1TableNbr].name + "_"+ tables[level2TableNbr].name + "_"+ tables[level3TableNbr].name;
			var searchTriple = "usernames_attempts_problems";
			alert("searchTriple=" + searchTriple);
			if (dbkeyTriples[i].keyname === searchTriple) {
				alert("keyname=" + dbkeyTriples[i].keyname);
				primary1 = dbkeyTriples[i].primary1;
				var temp1 = primary1.split(".");
				secondary1 = dbkeyTriples[i].secondary1;
				onClause1 = " JOIN " + temp1[0] + " ON " + primary1 + " = " + secondary1;	
				primary2 = dbkeyTriples[i].primary2;
				var temp2 = primary2.split(".");
				secondary2 = dbkeyTriples[i].secondary2;
				onClause2 = " JOIN " + temp2[0] + " ON " + primary2 + " = " + secondary2;	
				if (primary1.length >  0) {
					orderClause = " ORDER BY " + dbkeyTriples[i].sort;
				}
				break;
			}
		}
		alert(onClause1 + " " + onClause2);
		
		debugAlert(orderClause);
		
		var queryString = "SELECT " + selectClause + " FROM " + tables[level1TableNbr].name  + onClause1 + onClause2  + whereClause + orderClause + ";";
		debugAlert(queryString);

		document.getElementById("currentQuery").innerHTML = queryString;
		document.getElementById("resultsQuery").innerHTML = queryString;
	}

	
    function runTestQuery(tquery) {
        var xmlhttp;
    		
        
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
            //alert("view ready");
            document.getElementById("resultsView").innerHTML = xmlhttp.responseText;
            //$('#viewModal').modal('toggle')
          }
        };
	    var cmd = "RunTestQuery?testQuery=" + document.getElementById("resultsQuery").innerHTML;
	    //alert(cmd);
        xmlhttp.open("GET", cmd, true);
        xmlhttp.send();
      }

    function toggleColumnModal() {
    	$('#columnsModal').modal('toggle')
    }
</script>

</head>
<body>
    <header>
      <nav id="header-nav" class="navbar navbar-default">
        <div class="container">
          <div class="navbar-header">

            <div class="navbar-brand">
              <a href="ResearcherView.jsp">
                <h2><%= rb.getString("researcher")%> <%= rb.getString("dashboard")%></h2>
              </a>
            </div>

            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#collapsable-nav">
              <span class="sr-only">Toggle navigation</span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
          </div>

          <div id="collapsable-nav" class="collapse navbar-collapse">
            <ul id="nav-list" class="nav navbar-nav navbar-left">
              <li>
                <a>
                  <span class=" glyphicon fas fa-umbrella" ></span><br class="hidden-xs">Overview</a>
              </li>
              <li>
                <a onclick='getWorlds()'>
                  <span class="glyphicon glyphicon-globe"></span><br class="hidden-xs">Worlds</a>
              </li>
              <li onclick='getAttempts()'>
                <a>
                  <span class="glyphicon fas fa-tasks"></span><br class="hidden-xs">Assignments</a>
              </li>
              <li onclick='getProblems()'>
                <a>
                  <span class="glyphicon glyphicon-pencil"></span><br class="hidden-xs">Problems</a>
              </li>
              <li>
                <a>
                  <span class=" glyphicon fas fa-users" ></span><br class="hidden-xs">Classrooms</a>
              </li>
              <li  onclick='getStudents()'>
                <a>
                  <span class=" glyphicon fas fa-user-graduate" ></span><br class="hidden-xs">Students</a>
              </li>
             <li>
              <a id="Button" href='/fh2tReportingWeb/index.jsp'>
                <span class="glyphicon glyphicon-log-in"></span><br class="hidden-xs">Sign Out</a>
             </li>
            </ul><!-- #nav-list -->
          </div><!-- .collapse .navbar-collapse -->
        </div><!-- .container -->
      </nav><!-- #header-nav -->

    </header>
    
    <div id="columnsModal" class="modal" role="dialog">
      <div class="modal-dialog modal-lg" role="content">
        <!-- Modal content-->
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title"><%= rb.getString("select_columns")%></h4>
            <button type="button" class="close btn-danger" data-dismiss="modal">&times;</button>
          </div>
          <div class="modal-body">
            <form>
              <div id="columnRow" class="form-row">
    			<div class="col-md-4">
    				<div id="columnSelect">
	    			</div>
                	<div class="col-md-3 offset-md-4"><button type="button" class=" btn btn-primary btn-md ml-auto" onclick='saveSelectedColumns()'><%= rb.getString("select")%></button>  </div>
    			</div>
    			<div class="col-md-4">
    				<div id="columnOrder">
	    			</div>
                	<div class="col-md-3 offset-md-4"><button type="button" class=" btn btn-primary btn-md ml-auto" onclick='saveOrderColumns()'><%= rb.getString("order")%></button>  </div>
    			</div>
    			<div class="col-md-4">
    				<div id="columnGroup">
	    			</div>
                	<div class="col-md-3 offset-md-4"><button type="button" class="btn btn-primary btn-md ml-auto" onclick='saveGroupColumns()'><%= rb.getString("group")%></button>  </div>
    			</div>
    		  </div>
              <div class="form-row">
              	<div class="text-center" style="min-width: 500px;background-color: lightblue"><span><h3>Choose options from left to right.</h3></span></div> 
              </div>
              <div class="form-row">
                	<div class="pull-right"><button type="button" class="btn btn-success btn-md ml-auto" onclick='toggleColumnModal()'><%= rb.getString("submit")%></button>  </div>
                	<div class="pull-right"><button type="button" class="btn btn-danger btn-md ml-auto" onclick='clearWorkArea();toggleColumnModal()'><%= rb.getString("cancel")%></button> </div>
              </div>
              <div class="form-row">
              	<div style="min-width: 500px;min-height: 16px;background-color: lightblue"><span><h3></h3></span></div> 
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
    
    <div id="viewModal" class="modal fade" role="dialog">
      <div class="modal-dialog modal-lg" role="content">
        <!-- Modal content-->
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">Results of Current Query</h4>
            <button type="button" class="close btn-danger" data-dismiss="modal">&times;</button>
          </div>
          <div class="modal-body">
      		<div class="row">
    			<div class="col-12">
	    			<div id="resultsQuery" class="col-4"></div>
	    		</div>	
    		</div>
	      	<div class="row">
    			<div class="container">
    				<div id="viewer" >
	    			</div>
    			</div>
    		</div>
      		<div class="row">
    			<div class="col-2">
        			<h2></h2>
      			</div>
    			<div class="col-8">
        			<button type="button" class="btn btn-danger btn-lg ml-1 " onclick='close()'>Close</button>
      				<button type="button" class="btn btn-primary btn-lg ml-1 " onclick='close()'>Print</button>
      			</div>
    			<div class="col-2">
        			<h2></h2>
      			</div>
      		</div>
          </div>
        </div>
      </div>
    </div>
    
    <div id="editor" class="container-fluid editor">
      	<div id="level1" class="col-md-3 col-sm-6 col-xs-12v">
			<div class="col-4" id="level1Selection"></div>
      	</div>
      	
      	<div id="level2" class="col-md-3 col-sm-6 col-xs-12v">
    		<div class="col-4" id="level2Selection"></div>
	   	</div>
      	    	
      	<div id="level3" class="col-md-3 col-sm-6 col-xs-12v">
			<div class="col-4" id="level3Selection"></div>
      	</div>

      	<div id="level4" class="col-md-3 col-sm-6 col-xs-12v">
			<div class="col-4" id="level4Selection"></div>
      	</div>

    	<div class="row">
	      	<div class="col-md-12">
	      	</div>
      	</div>
      	
		<div class="row">
    		<div class="col-sm-4">
      			<h3></h3>
    		</div>
    		<div class="col-sm-4">
        		<button type="button" class="btn btn-danger btn-lg ml-1 " onclick='clearWorkArea()'>Clear</button>
        		<button type="button" class="offset-1 col-2 btn btn-primary btn-lg ml-1 " onclick='buildQuery()'>Build</button>
        		<button type="button" class="offset-1 col-2 btn btn-primary btn-lg ml-1 " onclick='runTestQuery()'>View</button>
        		<button type="button" class="offset-1 col-2 btn btn-primary btn-lg ml-1 ">Save</button>
    		</div>
    		<div class="col-sm-4">
      			<h3></h3>
    		</div>

  		</div>
  		
    	<div class="row">
	      	<div class="col-sm-4">
	      		<h1></h1>
			</div>    	
      	</div>

    </div>
    <div class="row">
    	<div id="tester" class="container-fluid tester">
			<div class="col-md-6" id="basicInfo" >
				<p>Basic Information</p>
				<p><h3>Student: FS0101-101  Problem # 1</h3></p>
			</div>  	
			<div class="col-md-6" id="problemInfo">
				<p>Problem Information</p>
				<p><h3> b+c+a  a+b+c</h3></p>
			</div>		
		</div>    
	</div>    
    <div class="footer">
      <div class="container">
        <div class="row">
          <div class="col-xs-12 text-center">
            <p class="glyphicon glyphicon-copyright-mark"> 2019 WPI</p>
          </div>
        </div>
      </div>
    </div>
<script>
$(document).ready(function () {
    $("#columnCancelButton").click(function () {
      $('#columnsModal').modal('toggle')
    });
  });
  
  
</script>

</body>

</html>