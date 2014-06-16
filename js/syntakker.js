var width = 1400,
    height = 900

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
  json.nodes.map(function (node) {
//     node.x=0;
//     node.y=0;
    force.nodes().push(node)
  });
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

  node.enter()
  .append("g")
  .attr("class", "node")
  .call(force.drag);

  node.append("circle")
  .attr("class", "node")
  .attr("r", 5);

  node.append("text")
  .attr("class", "node")
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
  force.nodes().push({name:newNodeName,x:0,y:0});
  restart();
}
