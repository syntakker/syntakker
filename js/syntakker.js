var width = 1400,
    height = 600

var svg = d3.select("body").append("svg")
.attr("width", width)
.attr("height", height);

var force = d3.layout.force()
.gravity(.05)
.distance(100)
.charge(-100)
.size([width, height]);

var nodes = force.nodes(),
    links = force.links(),
    node = svg.selectAll(".node"),
    link = svg.selectAll(".link");

d3.json("syntakker.json", function(error, json) {
  json.nodes.map(function (node) {force.nodes().push(node)});
  json.links.map(function (link) {force.links().push(link)});

  restart();
});

function restart()
{
  link = link
  .data(links);

  link.enter()
  .append("line")
  .attr("class", "link");

  node = node
  .data(nodes);

  var nodeEnter = node.enter()
  .append("g")
  .attr("class", "node")
  .call(force.drag);

  nodeEnter.append("circle")
  .attr("r", 5);

  nodeEnter.append("text")
  .attr("dx", 12)
  .attr("dy", ".35em")
  .text(function(d) { return d.name });

  force.start();

  force.on("tick", tick);
}

function tick(){
  link.attr("x1", function(d) { return d.source.x; })
  .attr("y1", function(d) { return d.source.y; })
  .attr("x2", function(d) { return d.target.x; })
  .attr("y2", function(d) { return d.target.y; });

  node.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });
}

function createNode() {
  var newNodeName = document.getElementById("newNode").value;
  var nodeExists = false;
  nodes.forEach(function(candidate){
    if (candidate.name == newNodeName) nodeExists = true;
  })
  if (!nodeExists) force.nodes().push({name:newNodeName,x:0,y:0});
  document.getElementById("nodelist").innerHTML = "";
  nodes.forEach(function(node){
    document.getElementById("nodelist").innerHTML += node.name + "<br/>";
  })
  restart();
}
