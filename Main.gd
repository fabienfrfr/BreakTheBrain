extends Node

const NeuralNet = preload("node/NeuralNet.gd")

export (PackedScene) var FixedNeuron
export (PackedScene) var InputX
export (PackedScene) var MovableNeuron

const nb_mv_neuron = 1
var movable_vertices = []
var vertices = []

var x_input_values = Array([])
var target_values = Array([])
var predicted_values = Array([])
const delta_x_val = 8.0
var points_count
var min_x
var max_x
var min_y
var max_y

var nn

func _ready():
	randomize()
	nn =  NeuralNet.new()
	$GraphGen.init_constructor(1,1,1,1)
	for _i in range(0,nb_mv_neuron):
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
	movable_vertices[-1].get_node("IN").points[1] = movable_vertices[-1].init_pos_in
	movable_vertices[-1].get_node("OUT").points[1] = movable_vertices[-1].init_pos_out

func curve_init():
	points_count = $TargetY.get_point_count()
	min_x = $TargetY.get_point_position(0).x
	max_x = $TargetY.get_point_position(points_count-1).x
	min_y = $PredictedY.get_point_position(0).y
	max_y = $PredictedY.get_point_position(points_count-1).y
	## to improve : curve solution
	for t in $TargetY.points :
		target_values += [(t.y-min_y)/(max_y-min_y)]
	for n in range(points_count) :
		predicted_values += [0]
		x_input_values += [delta_x_val*(float(n)/(points_count-1))-delta_x_val/2]
	_CurveUpdate()

func _CurveUpdate():
	# update movable neuron adjacency
	_check_connection()
	# compute graph prediction and error
	predicted_values = nn.graph2computation(x_input_values, $GraphGen.adj_matrix)
	var error = 0
	for n in range(points_count) :
		error += abs(target_values[n] - predicted_values[n])
		$PredictedY.points[n].y = min_y + (max_y-min_y)*predicted_values[n]
	error = error/points_count
	# update line2d and text score
	$GraphGen.update()
	$HUD/Error_abs.text = str(int(100*(1-error))) + " %"
	# dev test
	print($GraphGen.adj_matrix)
	
func _check_connection():
	var dist_in_list = []
	var dist_out_list = []
	var idx_in
	var idx_out
	for pn in $GraphGen.pos_node :
		dist_in_list += [(pn-movable_vertices[-1].absolut_position_in).length()]
		dist_out_list += [(pn-movable_vertices[-1].absolut_position_out).length()]
	idx_in = dist_in_list.find(dist_in_list.min())
	idx_out = dist_out_list.find(dist_out_list.min())
	if dist_in_list.min() < 25 :
		$GraphGen.adj_matrix[-2][idx_in] = movable_vertices[-1].Weight_in
	if dist_out_list.min() < 25 :
		$GraphGen.adj_matrix[idx_out][-2] = movable_vertices[-1].Weight_out
