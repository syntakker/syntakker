var width = 1400,
    height = 600

var svg = d3.select("body").append("svg")
.attr("width", width)
.attr("height", height);
svg.append("g").attr("class", "links");
svg.append("g").attr("class", "nodes");

var force = d3.layout.force()
.gravity(.015)
.distance(100)
.charge(-100)
.size([width, height]);

var nodes = force.nodes(),
    links = force.links(),
    node = svg.select(".nodes").selectAll(".node"),
    link = svg.select(".links").selectAll(".link");

var focusedNode;

d3.json("syntakker.json", function(error, json) {
  json.nodes.map(function (node) {force.nodes().push(node)});
  json.links.map(function (link) {force.links().push(link)});

  restart();
});

function focusNode(nodeName) {
  if (nodeName)
  {
    document.getElementById("focusedNode").innerHTML = "<span class=\"focusNode\">" + nodeName + "</span> <a href=\"#\" onclick=\"removeNode('" + nodeName + "')\"><img src=\"img/remove.png\"/></a>";
    document.getElementById("nodelist").innerHTML = "";
    nodes.forEach(function(node){
      if (node.name != nodeName)
      {
        if (findLink(nodeName, node.name) == null)
        {
          document.getElementById("nodelist").innerHTML += "<a href=\"#\" onclick=\"createLink('" + nodeName + "','" + node.name + "')\">" + node.name + "</a><br/>";
        } else {
          document.getElementById("nodelist").innerHTML += "<a class=\"linkedNode\" href=\"#\" onclick=\"removeLink('" + nodeName + "','" + node.name + "')\"><img src=\"img/chain.png\"/> " + node.name + "</a><br/>";
        }
      }
    })
    focusedNode = nodeName;
  } else {
    document.getElementById("focusedNode").innerHTML = "no node in focus...";
    document.getElementById("nodelist").innerHTML = "";
    focusedNode = null;
  }
}

function log(line)
{
  document.getElementById("log").innerHTML += line;
}

function findNode(nodeName)
{
  for (var i = 0; i < nodes.length; i++)
  {
    if (nodes[i].name == nodeName) return nodes[i];
  }
  return null;
}

function findLink(sourceName, targetName)
{
  for (var i = 0; i < links.length; i++)
  {
    if (links[i].source.name == sourceName && links[i].target.name == targetName) return links[i];
  }
  return null;
}

function removeNode(nodeName)
{
  var remove = [];
  for (var i = 0; i < links.length; i++)
  {
    if (links[i].source.name == nodeName || links[i].target.name == nodeName)
    {
      remove.push(i);
    }
  }
  while (remove.length > 0)
  {
    links.splice(remove.pop(),1);
  }
  for (var i = 0; i < nodes.length; i++)
  {
    if (nodes[i].name == nodeName)
    {
      nodes.splice(i,1);
      node.data(force.nodes(),function(d) {return d.name;}).exit().remove();
      break;
    }
  }
  focusNode(null);
  restart();
}


function removeLink(sourceName, targetName)
{
  for (var i = 0; i < links.length; i++)
  {
    if (links[i].source.name == sourceName && links[i].target.name == targetName)
    {
      links.splice(i,1);
      restart();
      if (focusedNode) focusNode(focusedNode);
      return;
    }
  }
}

function onNodeClick(d)
{
  focusNode(d.name);
}

function restart()
{
  link = link
  .data(links);

  link.enter()
  .append("line")
  .attr("class", "link");

  link.exit()
  .remove();

  node = node
  .data(nodes, function(d) {return d.name;});

  var nodeEnter = node.enter()
  .append("g")
  .attr("class", "node")
  .call(force.drag);

  nodeEnter.append("circle")
  .attr("r", 5)
  .on("click",onNodeClick);

  nodeEnter.append("text")
  .attr("dx", 12)
  .attr("dy", ".35em")
  .text(function(d) { return d.name });

  node.exit()
  .remove();

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

function createNode(newNodeName) {
  newNodeName = newNodeName.toString();
  if (findNode(newNodeName) == null)
  {
    force.nodes().push({name:newNodeName,x:0,y:0});
  }
  focusNode(newNodeName);
  restart();
}

function createLink(sourceName,targetName) {
  if (findLink(sourceName, targetName) == null)
  {
    source = findNode(sourceName);
    target = findNode(targetName);
    if (source != null && target != null) force.links().push({source:source, target:target});
    focusNode(sourceName);
    restart();
  }
}
