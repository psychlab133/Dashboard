<!DOCTYPE html>
<html>

<head>
    <meta charset='utf-8' />
    <title>Simple Bar chart</title>
    <script src="https://d3js.org/d3.v3.min.js" charset="utf-8"></script>
    <style>
        body {
            font-family: "Arial", sans-serif;
        }
        
        .bar {
            fill: #5f89ad;
        }
        
        .axis {
            font-size: 13px;
        }
        
        .axis path,
        .axis line {
            fill: none;
            display: none;
        }
        
        .label {
            font-size: 13px;
        }
    </style>

</head>

<body bgcolor="#E6E6FA">

    <div id="graphic"></div>

    <script>
        var data = [{
                "name": "0101-101",
                "value": 20,
        },
            {
                "name": "0101-102",
                "value": 12,
        },
            {
                "name": "0101-103",
                "value": 19,
        },
            {
                "name": "0101-104",
                "value": 5,
        },
            {
                "name": "0101-105",
                "value": 16,
        },
        {
            "name": "0101-106",
            "value": 26,
    },
    {
        "name": "0101-106",
        "value": 27,
},
{
    "name": "0101-107",
    "value": 28,
},
{
    "name": "0101-108",
    "value": 29,
},
{
    "name": "0101-109",
    "value": 30,
},
{
    "name": "0101-110",
    "value": 31,
},
{
    "name": "0101-111",
    "value": 32,
},
{
    "name": "0101-112",
    "value": 33,
},
{
    "name": "0101-113",
    "value": 34,
},
            {
                "name": "0101-114",
                "value": 35,
        }];

        data.length
        
        //sort bars based on value
        data = data.sort(function (a, b) {
            return d3.ascending(a.value, b.value);
        })

        //set up svg using margin conventions - we'll need plenty of room on the left for labels
        var margin = {
            top: 15,
            right: 25,
            bottom: 15,
            left: 60
        };

        var width = 960 - margin.left - margin.right,
            height = (data.length * 20) - margin.top - margin.bottom;

        var svg = d3.select("#graphic").append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
            .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        var x = d3.scale.linear()
            .range([0, width])
            .domain([0, d3.max(data, function (d) {
                return d.value;
            })]);

        var y = d3.scale.ordinal()
            .rangeRoundBands([height, 0], .1)
            .domain(data.map(function (d) {
                return d.name;
            }));

        //make y axis to show bar names
        var yAxis = d3.svg.axis()
            .scale(y)
            //no tick marks
            .tickSize(0)
            .orient("left");

        var gy = svg.append("g")
            .attr("class", "y axis")
            .call(yAxis)

        var bars = svg.selectAll(".bar")
            .data(data)
            .enter()
            .append("g")

        //append rects
        bars.append("rect")
            .attr("class", "bar")
            .attr("y", function (d) {
                return y(d.name);
            })
            .attr("height", y.rangeBand())
            .attr("x", 0)
            .attr("width", function (d) {
                return x(d.value);
            });

        //add a value label to the right of each bar
        bars.append("text")
            .attr("class", "label")
            //y position of the label is halfway down the bar
            .attr("y", function (d) {
                return y(d.name) + y.rangeBand() / 2 + 4;
            })
            //x position is 3 pixels to the right of the bar
            .attr("x", function (d) {
                return x(d.value) + 3;
            })
            .text(function (d) {
                return d.value;
            });
        
    </script>

</body>

</html>