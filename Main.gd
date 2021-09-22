extends Node

const NeuralNet = preload("node/NeuralNet.gd")

export (PackedScene) var FixedNeuron
export (PackedScene) var InputX
export (PackedScene) var MovableNeuron

const nb_i = 1
const nb_out = 1
var nb_fix = 2
var nb_mov = 2

var movable_vertices = []
var vertices = []

var x_input_values = Array([])
var target_values = Array([])
var predicted_values = Array([])
const delta_x_val = 8.0
var points_count = 100

const min_x = 40
const max_x = 720
const min_y = 560
const max_y = 500

var score: int
var try: int = 0
var nn

var n_time
var w_time

func _ready():
	n_time = 0
	w_time = $CurveUpdate.wait_time
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
	print(movable_vertices.size())
	# show curve
	curve_init()

func _reset_lvl():
	if try < 3 :
		print(try)
		# include 3 tries before reset all :
		for m in movable_vertices :
			m.get_node("IN").points[1] = m.init_pos_in
			m.get_node("OUT").points[1] = m.init_pos_out
		# forcing update matrix (why doesn't works always?)
		$GraphGen.adj_matrix = $GraphGen.adj_matrix_copy.duplicate(true)
		try += 1
	else :
		print('haha')
		try = 0
		# update difficulty :
		score = 1 - 1 # next difficulty
		var noding = $HUD._level_p_gen(nb_fix + nb_mov, score) # change nb_mov&fix
		# reset all :
		movable_vertices = []
		vertices = []
		_ready()

func curve_init():
	# line init
	$TargetY.clear_points()
	$PredictedY._initialization(points_count, min_x, max_x, min_y, max_y)
	for n in range(points_count):
		$TargetY.add_point(Vector2(min_x+n*(max_x-min_x)/(points_count-1),0))
	# linear input
	for n in range(points_count) :
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
	$PredictedY.update_path_and_point(predicted_values, n_time*w_time)
	var error = 0
	for n in range(points_count) :
		error += abs(target_values[n] - predicted_values[n])
	error = error/points_count
	# update text score
	$HUD/Error_abs.text = str(int(100*(1-error))) + " %"
	# update time
	n_time += 1
	
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
			m.get_node("IN").points[1] = -(m.position -  $GraphGen.pos_node[idx_in])*m.cm2pix
		if dist_out_list.min() < 25 :
			$GraphGen.adj_matrix[idx_out][-2] = m.Weight_out
			m.connected_out = true
			m.get_node("OUT").points[1] = -(m.position -  $GraphGen.pos_node[idx_out])*m.cm2pix
