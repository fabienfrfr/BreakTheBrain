extends Node2D

export var line_width = 5

export (PackedScene) var Edges

var pos_node = [Vector2(100,300),Vector2(400,100),Vector2(700,300)]
var adj_list = [[],[0],[1]]

var posA = Vector2.ZERO
var posB = Vector2.ZERO

var edges_list = []
var adj_matrix = []

var adj_matrix_copy
var offset

func init_constructor(nb_i, nb_out, nb_fix, nb_mov):
	var v = nb_i + nb_out + nb_fix + nb_mov
	var l = []
	for _i in range(v-1):
		for _j in range(v-1):
			l+= [0]
		adj_matrix += [l]
		l = []
	adj_matrix[0][0] = 1 # input
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

func update():
	offset = edges_list[-1].get_node("Line/WeightPath/WeighLvlFollow").unit_offset
	adj_matrix[1][adj_list[1][0]] = adj_matrix_copy[1][adj_list[1][0]] + 2.5*(0.5 - offset)
