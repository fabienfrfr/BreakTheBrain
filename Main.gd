extends Node

export (PackedScene) var FixedNeuron
export (PackedScene) var InputX
export (PackedScene) var MovableNeuron

var nb_mv_neuron = 1
var movable_vertices = []
var loc_position_mouse
var absolut_position_in
var absolut_position_out
var relative_pos_in
var relative_pos_out
var d_in
var d_out
var cm2pix = 3.7795275591

func _ready():
	randomize()
	var vertices = []
	for _i in range(0,nb_mv_neuron):
		movable_vertices += [MovableNeuron.instance()]
		add_child(movable_vertices[-1])
		$MovePath/NeuronSpawnLoc.offset = randi()
		movable_vertices[-1].position = $MovePath/NeuronSpawnLoc.position
	for i in range(0, $GraphGen.pos_node.size()) :
		if i == 0 :
			vertices += [InputX.instance()]
			add_child(vertices[-1])
		else :
			vertices += [FixedNeuron.instance()]
			add_child(vertices[-1])
		vertices[-1].position.x = $GraphGen.pos_node[i][0]
		vertices[-1].position.y = $GraphGen.pos_node[i][1]

func _process(_delta):
	loc_position_mouse = get_viewport().get_mouse_position()
	if Input.is_action_pressed("ui_accept"):
		relative_pos_in = movable_vertices[-1].get_node("IN").get_point_position(1)
		relative_pos_out = movable_vertices[-1].get_node("OUT").get_point_position(1)
		absolut_position_in = movable_vertices[-1].position + relative_pos_in / cm2pix
		absolut_position_out = movable_vertices[-1].position + relative_pos_out / cm2pix
		d_in = absolut_position_in - loc_position_mouse
		d_out = absolut_position_out - loc_position_mouse
		if d_in.length() < 25 :
			movable_vertices[-1].get_node("IN").points[1] = -(movable_vertices[-1].position - loc_position_mouse)*cm2pix
		elif d_out.length() < 25 :
			movable_vertices[-1].get_node("OUT").points[1] = -(movable_vertices[-1].position - loc_position_mouse)*cm2pix
