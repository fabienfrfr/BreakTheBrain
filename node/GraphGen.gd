extends Node2D

export var line_width = 5

export (PackedScene) var Edges

### to improve : generate node position and is param
var pos_node = [Vector2(100,300),Vector2(400,100),Vector2.ZERO,Vector2(700,300)]
#input, fixed, movable, output (init)
var type_n = ['input','fixed','movable','output']
var adj_list = [[],[0],[],[1]]
var weight = [[],[-1],[],[1]]
var biases = [1,1,1,-1]

var posA = Vector2.ZERO
var posB = Vector2.ZERO

var edges_list = []
var adj_matrix = []

var adj_matrix_copy
var offset

func init_constructor(nb_i, nb_out, nb_fix, nb_mov):
	var v = nb_i + nb_out + nb_fix + nb_mov
	var line = []
	# empty matrix
	for _i in range(v):
		for _j in range(v):
			line += [0]
		adj_matrix += [line]
		line = []
	# update matrix
	for i in range(v):
		# add biases
		adj_matrix[i][i] = biases[i]
		# add weight
		for l in adj_list[i]:
			adj_matrix[i][l] = weight[i][0]
	for i in range(1, adj_list.size()):
		var edge = [0]
		for l in adj_list[i] :
			# update
			posA = pos_node[l]
			posB = pos_node[i]
			# instance line
			edge = [Edges.instance()]
			add_child(edge[-1])
			# add edges
			edge[-1].add_link(posA,posB)
		edges_list += edge

func update():
	# to improve : generalize 
	for i in range(1, adj_list.size()):
		if edges_list[i-1] is (Node) :
			offset = edges_list[i-1].offset
			adj_matrix[i][adj_list[i][0]] = adj_matrix_copy[i][adj_list[i][0]] + 2.5*(0.5 - offset)
