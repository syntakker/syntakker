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
var focusedLinkType;
var linkTypes = {};

d3.json("syntakker.json", function(error, json) {
  json.nodes.map(function (node) {force.nodes().push(node)});
  json.links.map(function (link) {force.links().push(link)});
  focusNode(null);
  restart();
});

function focusNode(nodeName) {
  if (findNode(nodeName))
  {
    document.getElementById("focusedNode").innerHTML = "<span class=\"focusNode\">" + nodeName + "</span> <a href=\"#\" onclick=\"removeNode('" + nodeName + "')\"><img src=\"img/remove.png\"/></a>";
    document.getElementById("nodelist").innerHTML = "";
    focusedNode = nodeName;
    nodes.forEach(function(node){
      if (node.name != nodeName)
      {
        document.getElementById("nodelist").innerHTML += "<a href=\"#\" onclick=\"focusNode('" + node.name + "')\"><img src=\"img/focus.png\"/></a> ";
        var foundLink = findLink(nodeName, node.name)
        if (foundLink == null)
        {
          document.getElementById("nodelist").innerHTML += " <a href=\"#\" onclick=\"createLink('" + nodeName + "','" + node.name + "')\">" + node.name + "</a><br/>";
        } else {
          document.getElementById("nodelist").innerHTML += "<a class=\"linkedNode\" href=\"#\" onclick=\"removeLink('" + nodeName + "','" + node.name + "')\"><img src=\"img/chain.png\"/> "
          + (foundLink.linktype?"(" + foundLink.linktype + ") ":"") + node.name +"</a><br/>";
        }
      }
    });
  } else {
    document.getElementById("focusedNode").innerHTML = "no node in focus...";
    document.getElementById("nodelist").innerHTML = "";
    focusedNode = null;
    nodes.forEach(function(node){
      if (node.name != nodeName)
      {
        document.getElementById("nodelist").innerHTML += "<a href=\"#\" onclick=\"focusNode('" + node.name + "')\"><img src=\"img/focus.png\"/> " + node.name + "</a><br/>";
      }
    });
  }
}

function focusLinkType(linkTypeName) {
  var thisLinkType = findLinkType(linkTypeName);
  if (thisLinkType)
  {
    thisLinkType.toggle = true;
    focusedLinkType=linkTypeName;
    document.getElementById("focusedLinkType").innerHTML = "<span class=\"focusLinktype\">" + linkTypeName + "</span> <a href=\"#\" onclick=\"removeLinkType('" + linkTypeName + "')\"><img src=\"img/remove.png\"/></a>";
    document.getElementById("linkTypeList").innerHTML = "";
    for (var key in linkTypes)
    {
      var linkType = linkTypes[key];
      if (linkTypeName != linkType.name)
      {
        document.getElementById("linkTypeList").innerHTML += "<a href=\"#\" onclick=\"focusLinkType('" + linkType.name + "')\"><img src=\"img/focus.png\"/></a> ";
        if (linkType.toggle)
        {
          document.getElementById("linkTypeList").innerHTML += "<a class=\"activeLinkType\" href=\"#\" onclick=\"toggleLinkType('" + linkType.name + "')\"><img src=\"img/checked.png\"/> " + linkType.name + "</a><br/>";
        } else {
          document.getElementById("linkTypeList").innerHTML += "<a href=\"#\" onclick=\"toggleLinkType('" + linkType.name + "')\">" + linkType.name + "</a><br/>";
        }
      }
    }
  } else {
    focusedLinkType = null;
    document.getElementById("focusedLinkType").innerHTML = "no links in focus...";
    document.getElementById("linkTypeList").innerHTML = "";
    for (var key in linkTypes)
    {
      var linkType = linkTypes[key];
      document.getElementById("linkTypeList").innerHTML += "<a href=\"#\" onclick=\"focusLinkType('" + linkType.name + "')\"><img src=\"img/focus.png\"/></a> ";
      if (linkType.toggle)
      {
        document.getElementById("linkTypeList").innerHTML += "<a class=\"activeLinkType\" href=\"#\" onclick=\"toggleLinkType('" + linkType.name + "')\"><img src=\"img/checked.png\"/> " + linkType.name + "</a><br/>";
      } else {
        document.getElementById("linkTypeList").innerHTML += "<a href=\"#\" onclick=\"toggleLinkType('" + linkType.name + "')\">" + linkType.name + "</a><br/>";
      }
    }
  }
  tick();
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

function findLinkType(linkTypeName)
{
  return linkTypes[linkTypeName];
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
  .attr("class", "link" + (focusedLinkType?" _" + focusedLinkType:""));

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
  .attr("y2", function(d) { return d.target.y; })
  .style("stroke", function(d) {
    var linkType = findLinkType(d.linktype);
    if (linkType)
    {
      return linkType.toggle ? "#99ddee" : "rgba(85,119,136,0.3)"
    }
    return "rgba(85,119,136,0.3)";
  });

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
    if (source != null && target != null)
    {
      var newLink = {source:source, target:target};
      if (focusedLinkType) newLink.linktype = focusedLinkType;
      force.links().push(newLink);
    }
    focusNode(sourceName);
    restart();
  }
}

function createLinkType(newLinkTypeName) {
  if (findLinkType(newLinkTypeName) == null)
  {
    var newLinkType = {name:newLinkTypeName, toggle:true};
    linkTypes[newLinkTypeName] = newLinkType;
  }
  focusLinkType(newLinkTypeName);
}

function toggleLinkType(linkTypeName) {
  var linkType = findLinkType(linkTypeName);
  if (linkType)
  {
    linkType.toggle = !linkType.toggle;
    focusLinkType(focusedLinkType);
  }
  tick();
}

function exportGraph() {
  log("enter");
  d3.select("#export").style("display","block");
  var exportWindow = d3.select("#exportWindow");
  log("found");
  exportWindow.html(JSON.stringify({nodes:nodes, links:links, linkTypes:linkTypes}));
  exportWindow.style("display","block");
}
