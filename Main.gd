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
const delta_x_val = 16.0
var points_count
var min_x
var max_x
var min_y
var max_y

var nn

func _ready():
	randomize()
	nn =  NeuralNet.new()
	$GraphGen.constructor(1,1,2,1)
	for _i in range(0,nb_mv_neuron):
		movable_vertices += [MovableNeuron.instance()]
		add_child(movable_vertices[-1])
		$MovePath/NeuronSpawnLoc.offset = randi()
		movable_vertices[-1].position = $MovePath/NeuronSpawnLoc.position
	# NE PAS OUBLIER LE DECALAGE ENTRE LES DERNIERS NEURON ET LES MOUVABLE 
	for i in range(0, $GraphGen.pos_node.size()) :
		if i == 0 :
			vertices += [InputX.instance()]
			add_child(vertices[-1])
		else :
			vertices += [FixedNeuron.instance()]
			add_child(vertices[-1])
			$GraphGen.adj_matrix[i][$GraphGen.adj_list[i][0]] = vertices[-1].Weight
			$GraphGen.adj_matrix[i][i] =  vertices[-1].Biases
		vertices[-1].position.x = $GraphGen.pos_node[i][0]
		vertices[-1].position.y = $GraphGen.pos_node[i][1]
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
	for t in $TargetY.points :
		target_values += [(t.y-min_y)/(max_y-min_y)]
	for n in range(points_count) :
		predicted_values += [0]
		x_input_values += [delta_x_val*(float(n)/(points_count-1))-delta_x_val/2]
	_CurveUpdate()

func _CurveUpdate():
	nn.computational_graph(x_input_values, $GraphGen.adj_matrix)
	for n in range(points_count) :
		$PredictedY.points[n].y = min_y + (max_y-min_y)*predicted_values[n]
