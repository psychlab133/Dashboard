
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>

<%@ page import="javax.servlet.http.HttpSession"%>
<%@ page import="javax.servlet.http.HttpServletRequest"%>

<%@ page import="java.util.ResourceBundle"%>
    
<%@ page import="org.apache.log4j.Logger"%>
<%@ page import="org.apache.log4j.Level"%>

<%@ page import="edu.wpi.fh2t.utils.*"%>

<% 
session = request.getSession();
ResourceBundle rb = (ResourceBundle) session.getAttribute("rb");
Logger logger = (Logger) session.getAttribute("logger");
logger.setLevel(Level.INFO);
String ServerName = (String) request.getServerName();
//ServerName = "localhost";
logger.info("servername=" + ServerName);

Person currentUser = (Person) session.getAttribute("currentUser");
currentUser.setCurrentRole("Researcher");
String experimentAbbr = (String) session.getAttribute("expAbbr");
String experimentDisplay = (String) session.getAttribute("expDisplay");


logger.setLevel(Level.INFO);
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
    <script src='js/plotly.min.js'></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.9.1/underscore-min.js"></script>											
																								    
    <script>

   
    var serverName = "<%=ServerName%>";
    var currentUser = "<%=currentUser.getName()%>";
	var experimentAbbr = "<%=experimentAbbr%>";
	var experimentDisplay = "<%=experimentDisplay%>";
	
    var wideScreen = 0;

    var strVisualizer = "?data=\"Hello\"";
    
	var currentTableNbr = 0;

	var filter = "";
    var currentSchool = "06";
    var currentTeacher = "";
    var currentClassroom = "";
    var currentStudent = "";

    var currentProblem = "";
    var currentView = "";
    var resultsQuery = "";
    
    const REPORTS  = 1;
    const STUDENTS = 2;
    const WORLDS   = 3;
    const PROBLEMS = 4;
    const TRIALS   = 5;
    const EVENTS   = 6;
    const SCHOOLS  = 7;
    const TEACHERS = 8;
    const CLASSROOMS = 9;
         
    var tables = [
    	{"name":"","color":""},
    	{"name":"reports","color":"red"},
    	{"name":"usernames","color":"wheat"},
    	{"name":"worlds","color":"palegreen"},
    	{"name":"problems","color":"lightpink"},
    	{"name":"trials","color":"Orange"},
    	{"name":"events","color":"Orange"},
    	{"name":"schools","color":"paleturquoise"},
    	{"name":"teachers","color":"palegreen"},
    	{"name":"classrooms","color":"lemonchiffon"}
    
    ];
       
    function save() {
      //alert("Save");
    }
    function setFilter() {
    	  	
    	var role = "Researcher";

    	if (role == "Researcher") {
    		filter = experimentAbbr;
    		//alert("setFilter = " + filter);
    	}
    }
    function getStudents() {
      var xmlhttp;
      
      //alert("getStudents()");
      if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
        xmlhttp = new XMLHttpRequest();
      }
      else {// code for IE6, IE5
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
      }
      xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
            $("#shared-work-area").show();
          	document.getElementById("StudentSelection").innerHTML = xmlhttp.responseText;
//	  		if (currentStudent.length == 0) {
//				$("#avgBtn").show();
//				$("#sankeyBtn").show();
//				$("#treeMapBtn").show();
//		        $("#visualizerBtn").show();        
//		        $("#clearBtn").show();        
//			}
//			else {
//				$("#avgBtn").hide();
//				$("#sankeyBtn").hide();			
//				$("#treeMapBtn").hide();			
//		        $("#visualizerBtn").show();        
//		        $("#clearBtn").show();        
//			}
        }
      };

      if (filter.length == 0) {
      	filter = experimentAbbr;
      }
      	//alert("Student filter " + filter);
       	currentTableNbr = STUDENTS;
	
        var cmd = "";
        if (currentProblem == "") {
       		cmd = "GetStudents?tablecolor=" + tables[currentTableNbr].color + "\&filter=" + filter;
        }
        else {
       		cmd = "GetStudents?tablecolor=" + tables[currentTableNbr].color + "\&filter=" + filter + "\&problemId=" + currentProblem;       	
        }
      	xmlhttp.open("GET", cmd, true);
      	xmlhttp.send();
      
    }

    function getStudentView() {

	        $("#shared-work-area").show();
	        $("#worldViewBtn").hide();
	        $("#problemViewBtn").hide();
	        $("#getTeachersBtn").show();
	        $("#getClassroomsBtn").show();
	        $("#getStudentsBtn").show();
        }
    
    
    function getClassrooms() {
        var xmlhttp;
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
            document.getElementById("ClassroomSelection").innerHTML = xmlhttp.responseText;
            getStudents();
          }
        };
        
        if (filter.length == 0) {
        	filter = experimentAbbr;
        }
        //alert("Class filter " + filter);
       	currentTableNbr = CLASSROOMS;
    	
        var cmd = "";
        if (currentProblem == "") {
       		cmd = "GetClassrooms?tablecolor=" + tables[currentTableNbr].color + "\&filter=" + filter;
        }
        else {
       		cmd = "GetClassrooms?tablecolor=" + tables[currentTableNbr].color + "\&filter=" + filter + "\&problemId=" + currentProblem;       	
        }
		xmlhttp.open("GET", cmd, true);
       	xmlhttp.send();
        
      }

 
      function getTeachers() {
          var xmlhttp;
          //alert("getTeachers");

          if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
            xmlhttp = new XMLHttpRequest();
          }
          else {// code for IE6, IE5
            xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
          }
          xmlhttp.onreadystatechange = function () {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
              document.getElementById("TeacherSelection").innerHTML = xmlhttp.responseText;
              getClassrooms();
            }
          };
          
          if (filter.length == 0) {
          	filter = experimentAbbr;
          }
          	//alert("Teacher filter " + filter);
            currentTableNbr = TEACHERS;    	
            var cmd = "";
            if (currentProblem == "") {
           		cmd = "GetTeachers?tablecolor=" + tables[currentTableNbr].color + "\&filter=" + filter;
            }
            else {
           		cmd = "GetTeachers?tablecolor=" + tables[currentTableNbr].color + "\&filter=" + filter + "\&problemId=" + currentProblem;       	
            }
   			//alert(cmd);
   			xmlhttp.open("GET", cmd, true);
         	xmlhttp.send();          
        }
        
        function getSchools() {
            var xmlhttp;
            //alert("getSchools");

            if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
              xmlhttp = new XMLHttpRequest();
            }
            else {// code for IE6, IE5
              xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
            }
            xmlhttp.onreadystatechange = function () {
              if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
                document.getElementById("SchoolSelection").innerHTML = xmlhttp.responseText;
                getTeachers();
              }
            };

            if (filter.length == 0) {
            	filter = experimentAbbr;
            }
            //alert("School filter " + filter);
            currentTableNbr = SCHOOLS;
            var cmd = "";
            if (currentProblem == "") {
           		cmd = "GetSchools?tablecolor=" + tables[currentTableNbr].color + "\&filter=" + filter;
            }
            else {
           		cmd = "GetSchools?tablecolor=" + tables[currentTableNbr].color + "\&filter=" + filter + "\&problemId=" + currentProblem;       	
            }
   			//alert(cmd);
           	xmlhttp.open("GET", cmd, true);
           	xmlhttp.send();
            
          }



    function getProblems() {
        var xmlhttp;
        //alert("getProblems");
        
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {          
            //alert(xmlhttp.responseText);
            document.getElementById("ProblemSelection").innerHTML = xmlhttp.responseText;
          }
        };
        
        currentTableNbr = PROBLEMS;
       	var cmd = "GetProblems?tablecolor=" + tables[currentTableNbr].color;
       	//alert(cmd);
       	xmlhttp.open("GET", cmd, true);
       	xmlhttp.send();
        
      }

    
    function getProblemView() {

    	$("#shared-work-area").show();


        getProblems();
        currentView = "problemView";

      }
   
    function getTrialId(studentId,problemId) {
        var xmlhttp;
        //alert("getTrialId");
        

        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
        	
              //alert(xmlhttp.responseText);
              
              var temp = xmlhttp.responseText;
              
              var res = temp.split(",");
                            
              document.getElementById("visContent1").innerHTML = "<%= rb.getString("start_state")%>" + ": " + res[1];
              document.getElementById("visContent2").innerHTML = "<%= rb.getString("goal_state")%>"  + ": " + res[2];
              document.getElementById("visContent3").innerHTML = "<%= rb.getString("best_steps")%>"  + ": " + res[3];


			  getTrialEvents(res[0],studentId,problemId);
          }
        };
        
       	var cmd = "GetTrialId?studentId=" + studentId + "\&problemId=" + problemId;
        //alert(cmd);
       	xmlhttp.open("GET", cmd, true);
       	xmlhttp.send();
        
      }
    
    
    function resetTrials(){
    	$('select#trialsSelections option').removeAttr("selected");
    }
   
    function getTrialEvents(trialId,studentId,problemId) {
        var xmlhttp;
        //alert("getTrialEvents");
        
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }

        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
        	
        	//var txt = '[{"name":"John", "age":30, "city":"New York"}]'
        	//var obj = JSON.parse(txt);
            //var line = obj[0].name + ", " + obj[0].age;
            //alert("Test = " + line);
      	
        	//alert(xmlhttp.responseText);
        	
        	//var allData = JSON.parse(xmlhttp.responseText);
        	//document.getElementById("visualizerJSON").value = allData;
	   		//var visualizerForm= document.getElementById("visualizerForm");
	   		//visualizerForm.submit();

              
    	    //allData.forEach(myFunction); 
    	    //function myFunction(d, i, arr) {
    	    	//if (d["expr_ascii"] == null) {
    	    	//}
    	    	//else {
        	    	//var line = d["expr_ascii"];
    	    	//}
    	    //}
   	    	//alert(xmlhttp.responseText);
   	    	var resp = xmlhttp.responseText;
   	    	var iframeLine = "";
   	    	if (resp == "[]") {
   	    		alert("Problem not attempted");
   	    	}
   	    	else {  	
   	    		if (wideScreen == 1) {
 	                $("#visHeaderRow").show();
//		            $("#visContentRow").show();
   	    		    $("#wide-work-area").hide();
   	    		    iframeLine = "<iframe src='http://" + serverName + ":9000/clustervis_condensed.php?username=" + currentUser + "' width = '100%' height = '600' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>"
   	    		    document.getElementById("wideView").innerHTML =	iframeLine;
   	    			$("#wide-work-area").show();
   	    	        $("#screenshotViewBtn").show();
   	    		
   	    			

   	    		}
				if (wideScreen == 0) {
		      		getTrialMetrics(studentId,problemId);
		            $("#visHeaderRow").show();
		            $("#studentMetricsGrid").show();
		            $("#problemMetricsGrid").hide();
		   		    $("#visualizer").hide();
   	    		    iframeLine = "<iframe src='http://" + serverName + ":9000/clustervis.php?username=" + currentUser + "' width = '100%' height = '500' frameborder='2' marginwidth = '4' marginheight = '10' scrolling = 'yes'></iframe>";
					//alert(iframeLine);

					document.getElementById("resultsView").innerHTML =	iframeLine;
		   	    	$("#visualizer").show();
   	    	        $("#screenshotViewBtn").show();
   	    		}
   	    	}
    	    
          }
        };
        
        $("#visHeaderRow").hide();
//        $("#visContentRow").hide();
//        $("#gridHeader").hide();
        $("#studentMetricsGrid").hide();
	    $("#visualizer").hide();
    	$("#wide-work-area").show();
    	
    	document.getElementById("wideView").innerHTML = "";
    	document.getElementById("resultsView").innerHTML = "";
    	
       	var cmd = "GetTrialEvents?trialId=" + trialId;
       	//alert(cmd);
       	xmlhttp.open("GET", cmd, true);
       	xmlhttp.timeout = 10000;
       	xmlhttp.send();
      }

    function resetTrialEvents(){
    	$('select#eventsSelections option').removeAttr("selected");
    }

    
	  function fetchMetric(item, index) {
  	    document.getElementById("demo").innerHTML += index + ":" + item + "<br>";
  	  }

     function getProblemHdrs() {
          var xmlhttp;
          //alert("getProblemHdrs");

   
          if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
            xmlhttp = new XMLHttpRequest();
          }
          else {// code for IE6, IE5
            xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
          }
          xmlhttp.onreadystatechange = function () {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
          	  
                //alert(xmlhttp.responseText);
                var hdrs = JSON.parse(xmlhttp.responseText);
   
                //alert(hdrs.start_state);

            	$("#visHeaderRow").show();

                document.getElementById("visContent1").innerHTML = "start_state:" + hdrs.start_state;
                document.getElementById("visContent2").innerHTML = "goal_state:" + hdrs.goal_state;
                document.getElementById("visContent3").innerHTML = "best_step:" + hdrs.best_step;
            }
        };
          
       	var cmd = "GetProblemHdrs?problemId=" + currentProblem;
       	//alert(cmd);
       	xmlhttp.open("GET", cmd, true);
       	xmlhttp.send();
    }
	function getProblemSan(){
		if (experimentAbbr == 'F7S'){
			drawSankey();
	        $('#sankeyModalInt').modal('toggle');
		}else{
	        var xmlhttp;
	        //alert("getProblemSankey");

	        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
	            xmlhttp = new XMLHttpRequest();
	        }
	        else {// code for IE6, IE5
	            xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
	        }
	        xmlhttp.onreadystatechange = function () {
	           	if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
	         	   	//alert(xmlhttp.responseText);
	  				if (xmlhttp.responseText == "sankeyFiltered") {
	  					
	    				var problemNbr = currentProblem;
	    				if (problemNbr.length == 1) {
	    					problemNbr = "00" + problemNbr;
	    				}
	    				else {
	    					if ((problemNbr.length == 2)) {
	    						problemNbr = "0" + problemNbr;
	    					}	
	    				}
	    				
	    				//iframeLine = "<iframe frameborder='2' scrolling='yes' width='750px' height='500px' src='images/problem_" + problemNbr + "_Sankey_Filtered.png' name='imgbox' id='imgbox'> <p>iframes are not supported by your browser.</p> </iframe>";
	    				document.getElementById("sankeyImg").src =	'images/problem_' + problemNbr + '_Sankey_Filtered_' + filter + '.png';

	    		        $('#sankeyModal').modal('toggle');
	  				}
	   	           	else {
	   	           		alert("Diagram not available.");
	    	    		//$("#sankeyWindow").hide();
	   	           	}
	           }
	       };
	     	var cmd = "GetProblemSankey?problemId=" + currentProblem;
	      	//alert(cmd);
	      	xmlhttp.open("GET", cmd, true);
	      	xmlhttp.send();
	      						
		}
	}  
	function drawSankey(){
		var problemNbr = 'Pb_'+currentProblem+'_'+experimentAbbr;
		sankeyImg = document.getElementById("sankeyImgInt");

		Plotly.d3.json('json/'+problemNbr+'.json', function (fig) {
            problem_list = fig.Sheet1;

            var label = [];// To store expressions(unique) for each row id
            var n = [0];// To store the length of expressions(unique) for each row id

            /* Set of variables to generate the diagram */
            var source = [];
            var link_label = [];
            var target = [];
            var value = [];
            var lin_colour = [];

            var filtered = true;
            var sankey_type = 0;//0 Simple,  1 Productivity, 2 Pre-knowledge

            var mistake = false;

            /* To update for cluster data */
            var cluster_type = false;
            var cluster = 0;//0 All

            /* To get the list of 
            problems based on the data type */
            if (!cluster_type) {
                problem_01 = problem_list;
            } else if (cluster == 0) {
                problem_01 = _.sortBy(problem_list, 'cluster');
            } else {
                problem_01 = _.filter(problem_list, function (ans) {
                    return ans.cluster == "Cluster" + cluster
                });
            }

            /* sort row id, for each row id get
             unique expression in label */
            _.sortBy(_.uniq(_.map(problem_01, function (elem) {
                return elem.row_id
            })), function (row) {
                return parseInt(row)
            }).forEach(function (val) {
                label.push(_.uniq(_.map(_.filter(problem_01, function (ans) {
                    return ans.row_id == val
                }), function (valu) {
                    return valu.expr_ascii
                })));
                n.push(label.flat().length);
            });

            var problem_row = (_.find(problem_01, function (num) {
                return num.row_id == 0;
            }));
            //var prob_no = problem_row.problem_id;
            //var start_state = problem_row.start_state;
            //var end_state = problem_row.goal_state;
            var fh2t_user = _.uniq(_.map(problem_01, function (num) {
                return num.trial_id;
            }));//unique students

            fh2t_user.forEach(function (element) {
                var student_list = _.sortBy(_.filter(problem_01, function (num) {
                    return num.trial_id == element;
                }), function (val) {
                    return parseInt(val.row_id);
                });
                var expr_ascii_list = _.map(student_list, function (elem) {
                    return elem.expr_ascii;
                });// for each student get expressions
                var productivity = _.map(student_list, function (elem) {
                    return elem.productivity;
                });
                var cluster_list = _.map(student_list, function (elem) {
                    return elem.cluster;
                });
                var action_list = _.map(student_list, function (elem) {
                    return elem.action;
                });
                var prior_know = _.map(student_list, function (elem) {
                    return elem["prior-knowledge"];
                });

                // For Filtered Sankey
                if (filtered) {
                    if (expr_ascii_list.length > 11) {
                        return;
                    }
                    var should_ret = true;
                    for (i = 1; i < expr_ascii_list.length - 1 || i == 1; i++) {// To eliminate all single paths
                        if (_.filter(problem_01, function (exp) {
                            return exp.row_id == i && exp.expr_ascii == expr_ascii_list[i]
                        }).length > 1) {
                            should_ret = false;
                            break;
                        }
                    }
                    if (should_ret) {
                        return;
                    }
                }

                for (i = 0; i < expr_ascii_list.length - 1; i++) {
                    // for (i = 0; i < 10; i++) {
                    var source_index = label[i].indexOf(expr_ascii_list[i]) + n[i];
                    var target_index = label[i + 1].indexOf(expr_ascii_list[i + 1]) + n[i + 1];

                    // To increase the count for same path between two same nodes(expressions)
                    var source_list = source.reduce(function (a, e, i) {
                        if (e === source_index)
                            a.push(i);
                        return a;
                    }, []);
                    var target_list = target.reduce(function (a, e, i) {
                        if (e === target_index)
                            a.push(i);
                        return a;
                    }, []);
                    var link_label_list = link_label.reduce(function (a, e, ind) {
                        if (e === cluster_list[i])
                            a.push(ind);
                        return a;
                    }, []);
                    var indx = _.intersection(source_list, target_list, link_label_list);
                    if (indx.length > 0) {
                        value[indx[0]] += 1;
                    } else {// Following works if its a new path between two same nodes(expressions)
                        source.push(source_index);
                        target.push(target_index);
                        link_label.push(cluster_list[i]);
                        value.push(1);

                        /* Assigning colors for cluster data */
                        if (cluster_type && sankey_type == 0) {
                            if (cluster_list[i + 1] == "Cluster1") {
                                lin_colour.push("rgba(159, 37, 247,0.6)")

                            } else if (cluster_list[i + 1] == "Cluster2") {
                                lin_colour.push("rgba(11, 222, 0,0.4)")

                            } else if (cluster_list[i + 1] == "Cluster3") {
                                lin_colour.push("rgba(0, 0, 255,0.5)")

                            } else if (cluster_list[i + 1] == "Cluster4") {
                                lin_colour.push("rgba(247, 37, 37,0.5)")

                            }
                        }

                        /* Assigning colors for sankey type */
                        if (sankey_type == 1) {
                            if (productivity[i + 1]) {
                                if (productivity[i + 1] == "Yes") {
                                    lin_colour.push("rgba(0, 0, 255,0.5)")
                                } else {
                                    lin_colour.push("rgba(255, 0, 0,0.5)")
                                }
                            } else {
                                lin_colour.push("rgba(68, 68, 68, 0.2)")
                            }
                        }
                        if (sankey_type == 2) {
                            if (prior_know[i + 1]) {
                                if (prior_know[i + 1] == "high") {
                                    lin_colour.push("rgba(0, 255, 0,0.5)")
                                } else {
                                    lin_colour.push("rgba(255, 0, 0,0.5)")
                                }
                            } else {
                                lin_colour.push("rgba(68, 68, 68, 0.2)")
                            }
                        }

                        /* Assigning colors for action */
                        if (mistake) {
                            if (action_list[i]) {
                                if (action_list[i] == "mistake") {
                                    lin_colour.push("rgba(255, 0, 0,0.5)")
                                }
                            } else {
                                lin_colour.push("rgba(68, 68, 68, 0.2)")
                            }
                        }
                    }
                }
            });

            /* Default sankey type */
            if (sankey_type == 0 && !cluster_type && !mistake) {
                lin_colour = Array(source.length).fill("rgba(68, 68, 68, 0.2)")
            }
            var color = Array(label.flat().length).fill("black");
            var data = {
                type: "sankey",
                domain: {
                    x: [0, 1],
                    y: [0, 1]
                },
                orientation: "h",
                node: {
                    pad: 10,
                    thickness: 5,
                    /*line: {
                        color: "blue",
                        width: 0.5
                    },*/
                    valueformat: ".0f",
                    valuesuffix: "TWh",
                    label: label.flat(),
                    color: color
                },

                link: {
                    source: source,
                    target: target,
                    value: value,
                    color: lin_colour,
                    label: link_label
                }
            }

            var data = [data]

            var layout = {
                //title: "Problem number: " + prob_no + "<br>Start State: " + start_state + "<br>Goal State: " + end_state,
                title: "Problem number : "+currentProblem,
                width: 7200,
                height: 800,
                font: {
                    size: 15,
                    color: "Black",
                    weight: 900
                }
            }

            Plotly.newPlot(sankeyImg, data, layout, { displaylogo: false, displayModeBar: true })
        });
	}
    function getProblemSankey() {
        var xmlhttp;
        //alert("getProblemSankey");

        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
            xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
            xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
           	if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
         	   	//alert(xmlhttp.responseText);
  				if (xmlhttp.responseText == "sankeyFiltered") {
  					
    				var problemNbr = currentProblem;
    				if (problemNbr.length == 1) {
    					problemNbr = "00" + problemNbr;
    				}
    				else {
    					if ((problemNbr.length == 2)) {
    						problemNbr = "0" + problemNbr;
    					}	
    				}
    				
    				iframeLine = "<iframe frameborder='2' scrolling='yes' width='750px' height='500px' src='images/problem_" + problemNbr + "_Sankey_Filtered.png' name='imgbox' id='imgbox'> <p>iframes are not supported by your browser.</p> </iframe>";
    				document.getElementById("sankeyView").innerHTML =	iframeLine;

    	    		$("#sankeyWindow").show();
  				}
   	           	else {
   	           		alert("Diagram not available.");
    	    		$("#sankeyWindow").hide();
   	           	}
           }
       };
     	var cmd = "GetProblemSankey?problemId=" + currentProblem;
      	//alert(cmd);
      	xmlhttp.open("GET", cmd, true);
      	xmlhttp.send();
   }
       function getProblemTree(){
           var xmlhttp;
           //alert("getProblemTreeMap");

           if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
               xmlhttp = new XMLHttpRequest();
           }
           else {// code for IE6, IE5
               xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
           }
           xmlhttp.onreadystatechange = function () {
              	if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
            	   	//alert(xmlhttp.responseText);
     				if (xmlhttp.responseText == "treeMap") {

        				var problemNbr = currentProblem;
        				if (problemNbr.length == 1) {
        					problemNbr = "00" + problemNbr;
        				}
        				else {
        					if ((problemNbr.length == 2)) {
        						problemNbr = "0" + problemNbr;
        					}	
        				}

        				document.getElementById("sankeyImg").src =	'images/problem_' + problemNbr + '_Treemap_' + filter + '.png';

        		        $('#sankeyModal').modal('toggle');
     				}
      	           	else {
      	           		alert("Diagram not available.");
       	    			//$("#treeMapWindow").hide();
      	           	}
              }
          };
            
      	var cmd = "GetProblemTreeMap?problemId=" + currentProblem;
      	//alert(cmd);
      	xmlhttp.open("GET", cmd, true);
      	xmlhttp.send();    	   
       }  
       function getProblemTreeMap() {
           var xmlhttp;
           //alert("getProblemTreeMap");

           if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
               xmlhttp = new XMLHttpRequest();
           }
           else {// code for IE6, IE5
               xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
           }
           xmlhttp.onreadystatechange = function () {
              	if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
            	   	//alert(xmlhttp.responseText);
     				if (xmlhttp.responseText == "treeMap") {

        				var problemNbr = currentProblem;
        				if (problemNbr.length == 1) {
        					problemNbr = "00" + problemNbr;
        				}
        				else {
        					if ((problemNbr.length == 2)) {
        						problemNbr = "0" + problemNbr;
        					}	
        				}

       					iframeLine = "<iframe frameborder='2' scrolling='yes' width='600px' height='500px' src='images/problem_" + problemNbr + "_Treemap.png' name='imgbox' id='imgbox'> <p>iframes are not supported by your browser.</p> </iframe>";
       					document.getElementById("treeMapView").innerHTML =	iframeLine;
       		
       	    			$("#treeMapWindow").show();
     				}
      	           	else {
      	           		//alert("Diagram not available.");
       	    			$("#treeMapWindow").hide();
      	           	}
              }
          };
            
      	var cmd = "GetProblemTreeMap?problemId=" + currentProblem;
      	//alert(cmd);
      	xmlhttp.open("GET", cmd, true);
      	xmlhttp.send();
   }
	  
	  
	  
	  
    function getProblemAvgs() {
        var xmlhttp;
        //alert("getProblemAvgs");

 
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {

       	  
              var metrics = JSON.parse(xmlhttp.responseText);
              //alert(xmlhttp.responseText);
 			if (metrics.Students == 0){
 				$('#studentModal').modal('toggle');
 			}else
 			{
              var body = "";
              for (x in metrics) {
  		        
            	  var theMetric = x.split("~");
            	  if (theMetric[1] == "time_interaction") {
              		  var strMetric = metrics[x];
            		  var theValues = strMetric.split("~");
            		  
                      timeInteraction = parseFloat(theValues[1]);
                      whole = timeInteraction / 1000;
                      var avgTimeInteraction = "" + whole;
                      if (avgTimeInteraction.length > 7) {
                    	  avgTimeInteraction = avgTimeInteraction.substring(0,7)
                      }

              		  body += "<tr><td class='metricCell'>" + theMetric[0] +  "<span class='metrictooltip'>" + theMetric[2] + "</span></td><td>" + avgTimeInteraction + "</td></tr>" ;
            		  
            	  }
            	  else {
            		var strMetric = metrics[x];
            		var theValues = strMetric.split("~");
            		body += "<tr><td class='metricCell'>" + theMetric[0] +  "<span class='metrictooltip'>" + theMetric[2] + "</span></td><td>" + theValues[1] + "</td></tr>" ;
            	  }
            	  //alert(body);
              }
      	  	  document.getElementById("problemMetricsTable").innerHTML = body;
              $("#problemMetricsGrid").show();
              $("#studentMetricsGrid").hide();
              getProblemHdrs();
            //$("#gridHeader").show();
          }
            }
        };

		if (currentProblem.length > 0) {
	       	var cmd = "GetProblemAvgs?problemId=" + currentProblem;
	       	//alert(cmd);
	       	xmlhttp.open("GET", cmd, true);
	       	xmlhttp.send();    
		}
		else {
			alert("<%= rb.getString("please_select_problem")%>");
		}
    }


    function getTrialMetrics(studentId,problemId) {
        var xmlhttp;
        //alert("getTrialMetrics");

 
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
       	  
              var metrics = JSON.parse(xmlhttp.responseText);
              //alert(xmlhttp.responseText);
 
              var body = "";
              for (x in metrics) {
  		        
            	  var theMetric = x.split("~");
            	  if (theMetric[1] == "time_interaction") {
              		  var strMetric = metrics[x];
            		  var theValues = strMetric.split("~");
            		  
                      var timeInteraction = parseFloat(theValues[0]);
                      var whole = timeInteraction / 1000;
                      var strTimeInteraction = "" + whole;

                      timeInteraction = parseFloat(theValues[1]);
                      whole = timeInteraction / 1000;
                      var avgTimeInteraction = "" + whole;
                      if (avgTimeInteraction.length > 7) {
                    	  avgTimeInteraction = avgTimeInteraction.substring(0,7)
                      }

              		  body += "<tr><td class='metricCell'>" + theMetric[0] + "<span class='metrictooltip'>" + theMetric[2] + "</span></td><td>" + strTimeInteraction + "</td><td>" + avgTimeInteraction + "</td></tr>" ;
            		  
            	  }
            	  else {
            		var strMetric = metrics[x];
            		var theValues = strMetric.split("~");
            		body += "<tr><td class='metricCell'>" + theMetric[0] + "<span class='metrictooltip'>" + theMetric[2] + "</span></td><td>" + theValues[0] + "</td><td>" + theValues[1] + "</td></tr>" ;
            	  }
            	  //alert(body);
              }
      	  	  document.getElementById("studentsMetricsTable").innerHTML = body;
            }
        };

//        <td class="metricCell">1, 2 
//        <span class="tooltip">Tooltip</span> 
//    </td> 

        
       	var cmd = "GetTrialMetrics?studentId=" + studentId + "\&problemId=" + problemId;
       	//alert(cmd);
       	xmlhttp.open("GET", cmd, true);
       	xmlhttp.send();
      }

    function downloadFile(filename) {
        var xmlhttp;
        //alert("filename=" + filename);
 
        if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
          xmlhttp = new XMLHttpRequest();
        }
        else {// code for IE6, IE5
          xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        xmlhttp.onreadystatechange = function () {
          	if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
        	  
  		    	var emsg = xmlhttp.getResponseHeader("Content-Disposition");

        	  	if (emsg == "ErrorMsg") {
            		alert("File not found: " + filename);        	          		  
        	  	}
        	  	else {
	        	  	var element = document.createElement('a');
	        	  	element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(xmlhttp.responseText));
	        	  	element.setAttribute('download', filename);
	
	        	  	element.style.display = 'none';
	        	  	document.body.appendChild(element);
	
	        	  	element.click();
	
	        	  	document.body.removeChild(element);
        	  	}
          	} 
        };
        
       	var cmd = "DownloadFile?filename=" + filename;// + "&problemId=" + currentProblem;
       	//alert(cmd);
       	xmlhttp.open("GET", cmd, true);
       	xmlhttp.send();
      }

    function downloadImage(filename){
    	var problemNbr = currentProblem;
		if (problemNbr.length == 1) {
			problemNbr = "00" + problemNbr;
		}
		else {
			if ((problemNbr.length == 2)) {
				problemNbr = "0" + problemNbr;
			}	
		}
		
	  	var element = document.createElement('a');
	  	element.setAttribute('href', 'images/problem_' + problemNbr + '_' + filename + '_' + filter + '.png');
	  	element.setAttribute('download', 'Problem ' + currentProblem + ' ' + filename);

	  	element.style.display = 'none';
	  	document.body.appendChild(element);

	  	element.click();

	  	document.body.removeChild(element); 
    }

    /* function downloadProblemViz(filename){
	  	var element = document.createElement('a');
	  	element.setAttribute('href', 'pdf/Viz.pdf');
	  	element.setAttribute('download', filename);

	  	element.style.display = 'none';
	  	document.body.appendChild(element);

	  	element.click();

	  	document.body.removeChild(element);    	
    } */

    
    function clearWorkArea() {
		
		
		//currentSchool = "";
		currentTeacher = "";
	    currentClassroom = "";
	    currentStudent = "";

		document.getElementById("resultsView").innerHTML = "";
        $("#visHeaderRow").hide();
	    $("#visualizer").hide();
	    $("#sankeyWindow").hide();
	    $("#treeMapWindow").hide();
	    $("#studentMetricsGrid").hide();
	    $("#problemMetricsGrid").hide();
		$("#wide-work-area").hide();
		$("#world-work-area").hide();    
        $("#problemViewBtn").show();   
	}
	function clearProblemArea() {
		
		currentSchool = "";
		currentTeacher = "";
	    currentClassroom = "";
	    currentStudent = "";
	    currentProblem = "";

	    document.getElementById("SchoolSelection").innerHTML = "";
	    document.getElementById("TeacherSelection").innerHTML = "";
	    document.getElementById("ClassroomSelection").innerHTML = "";
	    document.getElementById("StudentSelection").innerHTML = "";
	    document.getElementById("selectStudent").value = "";
		document.getElementById("resultsView").innerHTML = "";
        $("#visHeaderRow").hide();
	    $("#visualizer").hide();
		$("#sankeyWindow").hide();
		$("#treeMapWindow").hide();
	    $("#studentMetricsGrid").hide();
	    $("#problemMetricsGrid").hide();
        $("#avgBtn").hide();
        $("#sankeyBtn").hide();
        $("#treeMapBtn").hide();
        $("#screenshotViewBtn").hide();
        
        
        
//        $("#visualizerBtn").show();        
//        $("#clearBtn").show();        
        getProblems();
		$("#wide-work-area").hide();
		setFilter();
	        
	}
	
	
	function setupTrialVisualizer() {
					
//		if (currentView == "problemView") {
			var selectStudent = document.getElementById("selectStudent").value;
			if (selectStudent.length > 0 ) {
				currentStudent = selectStudent;
				//document.getElementById("usernamesSelections").selectedIndex = "0";
			}

			if (currentStudent.length > 0) {
				if (currentProblem.length > 0) {
					getTrialId(currentStudent,currentProblem);				
				}
				else {
					alert("<%= rb.getString("please_select_problem")%>");
				}
			}
			else {
				if (currentProblem.length > 0) {
					alert("<%= rb.getString("please_select_student")%>");
				}
				else {
					alert("<%= rb.getString("please_select_problem_student")%>");
				}
			}
//		}
	}
 
    function setSchool() {
    	var x = document.getElementById("schoolsSelections").value;
    	filter = x.substring(0,4);
    	currentSchool = x.substring(0,2);
    	currentTeacher = "";
    	currentClassroom = "";
    	currentStudent = "";
    	document.getElementById("selectStudent").value = filter;
		getTeachers();
      }

	function setTeacher() {
    	var x = document.getElementById("teachersSelections").value;
    	filter = x.substring(0,6);
    	currentSchool = x.substring(2,4);
    	currentTeacher = x.substring(4,6);
    	currentClassroom = "";
    	currentStudent = "";
    	document.getElementById("selectStudent").value = filter;
		getClassrooms();
      }

    function setClassroom() {
    	var x = document.getElementById("classroomsSelections").value;
    	filter = x.substring(0,8);
    	currentSchool = x.substring(2,4);
    	currentTeacher = x.substring(4,6);
    	currentClassroom = x.substring(7,8);
    	currentStudent = "";
    	document.getElementById("selectStudent").value = filter;
    	getStudents();
      }

    function setStudent() {
    	var x = document.getElementById("usernamesSelections").value;
    	currentSchool = x.substring(0,2);
    	currentTeacher = x.substring(2,6);
    	currentClassroom = x.substring(7,8);
    	currentStudent = x;
    	document.getElementById("selectStudent").value = x;
      }

    function setProblem() {
    	var x = document.getElementById("problemsSelections").value;
    	currentProblem = x;
	    $("#screenshotViewBtn").hide();
		getSchools();
		
		document.getElementById("sankeyView").innerHTML = " ";
		$("#sankeyWindow").show();
        $("#sankeyBtn").show();

        document.getElementById("treeMapView").innerHTML = " ";
        $("#treeMapWindow").show();
        $("#treeMapBtn").show();
        
		document.getElementById("problemMetricsTable").innerHTML = " ";        
		$("#avgBtn").show();
      }
    
    function setWideScreen(onoff) {
    	wideScreen = onoff;
    }
    
    /* $("#sankeyView").click(function(){
    	alert("hi");
    });
    $("#sankeyWindow").click(function(){
    	alert("hi");
    });
    $("#imgbox").click(function(){
    	alert("hi");
    });
    /* $("#sankeyView").click(function(){
    	alert("hi");
    }); */
    $(document).ready(function () {
        $("#visualizer").hide();
        $("#sankeyWindow").hide();
        $("#treeMapWindow").hide();
        $("#studentMetricsGrid").hide();
	    $("#problemMetricsGrid").hide();
        $("#visHeaderRow").hide();
        $("#shared-work-area").hide();
        $("#getTrialsBtn").hide();
        $("#getTeachersBtn").hide();
        $("#getClassroomsBtn").hide();
        $("#getStudentsBtn").hide();
        $("#avgBtn").hide();
        $("#sankeyBtn").hide();
        $("#treeMapBtn").hide();
	    $("#screenshotViewBtn").hide();
/* 	    $("#sankeyView").click(function(){
	    	alert("hi");
	    });
	    $("#sankeyWindow").click(function(){
	    	alert("hi");
	    });
	    $("#imgbox").click(function(){
	    	alert("hi");
	    }); */
    	getProblemView();
    	var researcher = "<%= rb.getString("researcher")%>";
    	var dashboard = "<%= rb.getString("dashboard")%>";
    	var title1 = "<h4>" + researcher + " " + dashboard + "</h4>";
    	document.getElementById("ResearchPageTitle").innerHTML = title1;
    	var title2 = "<h4>" + experimentDisplay + "</h4>";
    	document.getElementById("ResearchPageExperiment").innerHTML = title2;

      });

</script>

</head>
<body>
	<header>
    <div class="row">
    	<div id="ResearchPageHeader">
    		<div id="ResearchPageExperiment" class="col-md-4 col-sm-12 col-xs-12v pull-left">	   	    	
    		</div>
    		<div id="ResearchPageTitle" class="col-md-6 col-sm-12 col-xs-12v pull-left">	   
    		</div>
    		<div id="ResearchPageSignoutButton"class="col-md-2 col-sm-12 col-xs-12v pull-right">
              	<a id="Button" href='/fh2tReportingWeb/index.jsp'>
                	<class="hidden-xs pull-right"><%= rb.getString("sign_out")%></a>
    		</div>	
    	</div>
    </div> 
    </header>
    
    
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
<div class="row">
	<div id="shared-work-area">
		<div id="left-panel" class="col-md-8 col-sm-12 col-xs-12v">	   
		   	<div class="row">
			    <div id="selectionPanel" class="container-fluid selectionPanel">
			    	<div id=menus class="col-md-12 col-sm-12 col-xs-12v">
				      	<div id="level1" class="col-md-3 col-sm-5 col-xs-12v">
							<div class="col-3" id="ProblemSelection"></div>
				      	</div>
				      	
				      	<div id="level2" class="col-md-2 col-sm-6 col-xs-12v">
				    		<div class="col-3" id="SchoolSelection"></div>
					   	</div>
				      	    	
				      	<div id="level3" class="col-md-2 col-sm-6 col-xs-12v">
							<div class="col-2" id="TeacherSelection"></div>
				      	</div>
				
				      	<div id="level4" class="col-md-2 col-sm-6 col-xs-12v">
							<div class="col-2" id="ClassroomSelection"></div>
				      	</div>
				      	
				      	<div id="level5" class="col-md-3 col-sm-6 col-xs-12v">
							<div class="col-2" id="StudentSelection"></div>
				      	</div>
			      	</div>
		      	</div>	
			
				<div class="col-md-12">
			    </div>
		    </div>
			<div id="btnrow" class="row">
	    		<div class="col-sm-12">
					<div class="form-group col-md-2">
	  					<input type="text" class="form-control pull-left" id="selectStudent" placeholder="Enter StudentID">
					</div>
	        		<button id="visualizerBtn" type="button" class="offset-1 col-2 btn btn-primary btn-md ml-1 pull-left " onclick='setWideScreen(0);setupTrialVisualizer()'><%= rb.getString("visualize")%></button>
	        		<button id="wideViewBtn"type="button" class="offset-1 col-2 btn btn-primary btn-md ml-1 pull-left hidden" onclick='setWideScreen(1);setupTrialVisualizer()'><%= rb.getString("wide_view")%></button>
					<a id='screenshotViewBtn' href='/fh2tReportingWeb/fh2tScreenshotVisualizer.jsp'  target='_blank' class='btn btn-primary btn-md ml-1' role='button'>Screenshot View</a>
	        		<button id="sankeyBtn"type="button" class="offset-1 col-2 btn btn-primary btn-md ml-1 pull-left " onclick='getProblemSan();'><%= rb.getString("flow_diagram")%></button>
	        		<button id="treeMapBtn"type="button" class="offset-1 col-2 btn btn-primary btn-md ml-1 pull-left " onclick='getProblemTree();'>TreeMap</button>
	        		<button id="avgBtn"type="button" class="offset-1 col-2 btn btn-primary btn-md ml-1 pull-left " onclick='getProblemAvgs();'>Problem Avgs</button>
	        		<button id="clearBtn"type="button" class="btn btn-danger btn-md ml-1 pull-left " onclick='clearProblemArea()'><%= rb.getString("clear")%></button>
	    		</div>
	    		<div class="col-sm-4">
	      			<h3></h3>
	    		</div>
	  		</div>
	  		
		   	<div id="visHeaderRow" class="row">
				<div class="col-md-5 visheader">
					<p id="visContent1"></p>		
				</div>		
				<div class="col-md-4 visheader"> 
					<p id="visContent2"></p>		
				</div>		
				<div class="col-md-3 visheader">
					<p id="visContent3"></p>		
				</div>		
			</div>
		   	<div class="row">
			    <div id="visualizer">
					<div class="col-md-12" id="resultsView" >
					</div>  	
				</div>    
			</div>	  		
			<div>
			   	<div class="row">
				    <div id="spacer" class="container-fluid ">
						<div class="col-md-12"  >
							<p>&nbsp;</p>
						</div>  	
					</div>    
				</div>
			</div>
			<div id="btnrow" class="row">
	    		<div class="col-sm-12">
						<button id="downloadOBtn" type="button"
							class="offset-1 col-2 btn btn-primary btn-sm ml-1 pull-left "
							onclick='downloadFile("aggregation_table_overall_level.csv")'>
							<strong><%=rb.getString("download")%><strong /> <br /><%=rb.getString("overall_level_data")%>
						</button>
						<button id="downloadPBtn" type="button"
							class="offset-1 col-2 btn btn-primary btn-sm ml-1 pull-left "
							onclick='downloadFile("aggregation_table_problem_level.csv")'><%=rb.getString("download")%>
							<br /><%=rb.getString("problem_level_data")%></button>
						<a href="pdf/Viz.pdf" download="Problem Level Visualization">
							<button id="downloadPVBtn" type="button"
								class="offset-1 col-2 btn btn-primary btn-sm ml-1 pull-left "><%=rb.getString("download")%>
								<br /><%=rb.getString("problem_level_vis")%></button>
						</a>
						<button id="downloadSanBtn" type="button"
							class="offset-1 col-2 btn btn-primary btn-sm ml-1 pull-left "
							onclick='downloadImage("Sankey_Filtered")'><%=rb.getString("download")%>
							<br /><%=rb.getString("sankey_dia")%></button>
						<button id="downloadTreeBtn" type="button"
							class="offset-1 col-2 btn btn-primary btn-sm ml-1 pull-left "
							onclick='downloadImage("Treemap")'><%= rb.getString("download")%>
							<br /><%= rb.getString("tree_map")%></button>
					</div>
	    		<div class="col-sm-4">
	      			<h3></h3>
	    		</div>
	  		</div>
	  		
	  		
	    </div>
		<div id="right-panel" class="col-md-4 col-sm-12 col-xs-12v">       

			

		    <div class="row">
				<div id="studentMetricsGrid" class="col-md-12" >
					
				  <table class="table table-striped table-bordered measuresTable">
				    <thead>
				      <tr>
				        <th><%= rb.getString("measures")%></th>
				        <th><%= rb.getString("student")%></th></th>
				        <th><%= rb.getString("overall_average")%></th></th>
				      </tr>
				    </thead>
				    <tbody id="studentsMetricsTable">
				    </tbody>
				  </table>
				</div>		
				<div id="problemMetricsGrid" class="col-md-12" >
					
				  <table class="table table-striped table-bordered measuresTable">
				    <tbody id="problemMetricsTable">
				    </tbody>
				  </table>
				</div>		
			</div>  	
			
			
		</div>
	</div>
	<div id="wide-work-area">
		   	<div class="row">
			    <div id="wideView" class="container-fluid ">
					<div class="col-md-12"  >
					</div>  	
				</div>    
			</div>
	</div>
	<div id="world-work-area">
		   	<div class="row">
			    <div id="worldView" class="container-fluid ">
					<div class="col-md-12"  >
					</div>  	
				</div>    
			</div>
	</div>
		   	<div class="row">
			    <div id="sankeyWindow">
					<div class="col-md-7" id="sankeyView" >
						<p>&nbsp;</p>					
					</div>  	
				</div>    
			    <div id="treeMapWindow">
					<div class="col-md-5" id="treeMapView" >
						<p>&nbsp;</p>					
					</div>  	
				</div>    
			</div>	  		

	<div>
		   	<div class="row">
			    <div id="spacer" class="container-fluid ">
					<div class="col-md-12"  >
						<p>&nbsp;</p>
					</div>  	
				</div>    
			</div>
	</div>
	
</div>

		<!-- Modal -->
		<div class="modal fade" id="sankeyModal" style="overflow-x:auto" tabindex="-1" role="dialog" >
		  <div class="modal-dialog modal-dialog-centered" style = "left:35%" role="content">
		          <img id = "sankeyImg" width='1000px' height='600px'></img>
		      <!-- Modal content-->
<!-- 		      <div class="modal-content">
		        <div class="about-modal-body"">
		        </div>
		      </div> -->
		  </div>
		</div>
		<div class="modal fade" id="sankeyModalInt" style="overflow-x:auto" tabindex="-1" role="dialog" >
		  <div class="modal-dialog modal-dialog-centered" style = "left:20%" role="content">
		          <div id = "sankeyImgInt"></div>
		      <!-- Modal content-->
<!-- 		      <div class="modal-content">
		        <div class="about-modal-body"">
		        </div>
		      </div> -->
		  </div>
		</div>
		<div class="modal fade" id="studentModal" tabindex="-1" role="dialog" >
		  <div class="modal-dialog modal-dialog-centered" role="content">
		      <div class="modal-content">
		        <div class="modal-header">
		          <h4 class="about-modal-header text-center">Researcher Dashboard</h4>
		        </div>
		        <div class="about-modal-body"">
		        <p></p>
		          <p>No students have completed the problem.</p>
		          <p></p>
		        </div>
		      </div>

		  </div>
		</div>
    <div class="footer">
      <div class="container">
        <div class="row">
          <div class="col-xs-12 text-center">
            <p class="glyphicon glyphicon-copyright-mark copyright"><%= rb.getString("copyright")%></p>
          </div>
        </div>
      </div>
    </div>



</body>

</html>