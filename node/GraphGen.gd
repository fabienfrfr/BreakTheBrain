extends Node2D

export var line_width = 5

export (PackedScene) var Edges

var pos_node = [[100,300],[400,100],[700,300]]
var adj_list = [[],[0],[1]]
var type_node = ["input","fixed","output"]

var posA = Vector2.ZERO
var posB = Vector2.ZERO

func _ready():
	var edges_list = []
	for i in range(1, adj_list.size()):
		# instance line
		edges_list += [Edges.instance()]
		add_child(edges_list[-1])
		# update node
		posA.x = pos_node[adj_list[i][0]][0]
		posA.y = pos_node[adj_list[i][0]][1]
		posB.x = pos_node[i][0]
		posB.y = pos_node[i][1]
		# add edges
		edges_list[-1].add_link(posA,posB)
