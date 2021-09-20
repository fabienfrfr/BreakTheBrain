extends Node2D

export var line_width = 5

export (PackedScene) var Edges

### define static type (faster)
var v_size
var pos_node
var type_n
var adj_list
var weight
var biases

var posA = Vector2.ZERO
var posB = Vector2.ZERO

var edges_list
var adj_matrix

var adj_matrix_copy
var offset

var x_in = 100
var x_out = 700
var y_sep = 300
var y_up = 50

func node_generator(nb_i, nb_out, nb_fix, nb_mov):
	var position = []
	var type_node = []
	var adj_list_ = []
	var weight_ = []
	var biaise_ = []
	var dy_i = 200/(nb_i+1)
	var dy_o = 200/(nb_out+1)
	var dist
	for i in range(nb_i):
		position += [Vector2(x_in,y_sep-100+(i+1)*dy_i)]
		type_node += ['input']
		adj_list_ += [[]]
		weight_ += [[]]
		biaise_ += [1]
	for _i in range(nb_fix):
		position += [Vector2(x_in+50+randi()%500,y_up+randi()%(y_sep-3*y_up))]
		type_node += ['fixed']
		dist = []
		for p in position :
			dist += [(position[-1]-p).length()]
		dist[-1] = 10000
		adj_list_ += [[dist.find(dist.min())]]
		weight_ += [[-1]]
		biaise_ += [1]
	for _i in range(nb_mov):
		position += [Vector2.ZERO]
		type_node += ['movable']
		adj_list_ += [[]]
		weight_ += [[]]
		biaise_ += [1]
	for i in range(nb_out):
		position += [Vector2(x_out,y_sep-100+(i+1)*dy_o)]
		type_node += ['output']
		dist = []
		for p in position :
			# forward propagation only (need to verify)
			if (position[-1]-p).x > 0 : 
				dist += [(position[-1]-p).length()]
			else :
				dist += [100000]
		adj_list_ += [[dist.find(dist.min())]]
		weight_ += [[1]]
		biaise_ += [-1]
	return [position, type_node, adj_list_, weight_, biaise_]

func init_constructor(nb_i, nb_out, nb_fix, nb_mov):
	v_size = nb_i + nb_out + nb_fix + nb_mov
	# generate position and param (to improve)
	var param = node_generator(nb_i, nb_out, nb_fix, nb_mov)
	pos_node = param[0]
	type_n = param[1]
	adj_list = param[2]
	weight = param[3]
	biases = param[4]
	# construct matrix
	adj_matrix = []
	var line = []
	# empty matrix
	for _i in range(v_size):
		for _j in range(v_size):
			line += [0]
		adj_matrix += [line]
		line = []
	# update matrix
	for i in range(v_size):
		# add biases
		adj_matrix[i][i] = biases[i]
		# add weight
		for l in adj_list[i]:
			adj_matrix[i][l] = weight[i][0]
	# edges construction
	edges_list = Array([])
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
	print(adj_matrix)

func _update(vertice):
	# to improve : generalize to multiple initial link
	for i in range(1, adj_list.size()):
		if edges_list[i-1] is (Node) :
			offset = edges_list[i-1].offset
			adj_matrix[i][adj_list[i][0]] = adj_matrix_copy[i][adj_list[i][0]] + 2.5*(0.5 - offset)
	# node biases update
	for i in range(1,vertice.size()) :
		if i == vertice.size() - 1 :
			adj_matrix[-1][-1] = adj_matrix_copy[-1][-1] + 1.5*(vertice[i].offset - 0.5)
		else :
			adj_matrix[i][i] = adj_matrix_copy[i][i] + 1.5*(vertice[i].offset - 0.5)
