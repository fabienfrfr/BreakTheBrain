extends Node

const NeuralNet = preload("node/NeuralNet.gd")

export (PackedScene) var FixedNeuron
export (PackedScene) var InputX
export (PackedScene) var MovableNeuron

const nb_i = 1
const nb_out = 1
const nb_fix = 1
const nb_mov = 1

var movable_vertices = []
var vertices = []

var x_input_values = Array([])
var target_values = Array([])
var predicted_values = Array([])
const delta_x_val = 8.0
var points_count
var min_x = 40
var max_x = 720
var min_y = 560
var max_y = 500

var score: int

var nn

func _ready():
	randomize()
	nn =  NeuralNet.new()
	$GraphGen.init_constructor(nb_i, nb_out, nb_fix, nb_mov)
	for _i in range(0,nb_mov):
		movable_vertices += [MovableNeuron.instance()]
		add_child(movable_vertices[-1])
		$MovePath/NeuronSpawnLoc.offset = randi()
		movable_vertices[-1].position = $MovePath/NeuronSpawnLoc.position
	for i in range($GraphGen.pos_node.size()) :
		if $GraphGen.type_n[i] == "input" :
			vertices += [InputX.instance()]
			add_child(vertices[-1])
		elif $GraphGen.type_n[i] == "fixed" or $GraphGen.type_n[i] == "output" :
			vertices += [FixedNeuron.instance()]
			add_child(vertices[-1])
		if  $GraphGen.type_n[i] != "movable" :
			vertices[-1].position.x = $GraphGen.pos_node[i][0]
			vertices[-1].position.y = $GraphGen.pos_node[i][1]
	# save matrix
	$GraphGen.adj_matrix_copy = $GraphGen.adj_matrix.duplicate(true)
	# show curve
	curve_init()

func _reset_lvl():
	score = 1 - 1 # next difficulty
	for m in movable_vertices :
		m.get_node("IN").points[1] = m.init_pos_in
		m.get_node("OUT").points[1] = m.init_pos_out
	# forcing update matrix (why doesn't works always?)
	$GraphGen.adj_matrix = $GraphGen.adj_matrix_copy.duplicate(true)
	#_ready()

func curve_init():
	points_count = $TargetY.get_point_count()
	for n in range(points_count) :
		predicted_values += [0]
		x_input_values += [delta_x_val*(float(n)/(points_count-1))-delta_x_val/2]
	## curve solution
	target_values = nn.solution_generator(x_input_values, nb_i+nb_fix, $GraphGen.pos_node, $GraphGen.adj_matrix, movable_vertices)
	for n in range(points_count):
		$TargetY.points[n].y = min_y + (max_y-min_y)*target_values[n]
	# update first curve
	_CurveUpdate()

func _CurveUpdate():
	# update movable neuron adjacency
	_check_connection()
	# update weight-biase
	$GraphGen._update(vertices)
	# compute graph prediction and error
	predicted_values = nn.graph2computation(x_input_values, $GraphGen.adj_matrix)
	predicted_values = nn.normalization(predicted_values)
	var error = 0
	for n in range(points_count) :
		error += abs(target_values[n] - predicted_values[n])
		$PredictedY.points[n].y = min_y + (max_y-min_y)*predicted_values[n]
	error = error/points_count
	# update text score
	$HUD/Error_abs.text = str(int(100*(1-error))) + " %"
	# dev test
	print($GraphGen.adj_matrix)
	
func _check_connection():
	for m in movable_vertices :
		var dist_in_list = []
		var dist_out_list = []
		var idx_in
		var idx_out
		var pn
		for i in range($GraphGen.v_size) :
			pn = $GraphGen.pos_node[i]
			if $GraphGen.type_n[i] != "movable" :
				dist_in_list += [(pn-m.absolut_position_in).length()]
				dist_out_list += [(pn-m.absolut_position_out).length()]
			else :
				dist_in_list += [1000]
				dist_out_list += [1000]
		idx_in = dist_in_list.find(dist_in_list.min())
		idx_out = dist_out_list.find(dist_out_list.min())
		if dist_in_list.min() < 25 :
			$GraphGen.adj_matrix[-2][idx_in] = m.Weight_in
			m.connected_in = true
		if dist_out_list.min() < 25 :
			$GraphGen.adj_matrix[idx_out][-2] = m.Weight_out
			m.connected_out = true
