extends Node

const NeuralNet = preload("node/NeuralNet.gd")

export (PackedScene) var FixedNeuron
export (PackedScene) var InputX
export (PackedScene) var MovableNeuron

const nb_mv_neuron = 1
var movable_vertices = []

func _ready():
	randomize()
	var nn =  NeuralNet.new()
	nn._ready()
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

func _reset_lvl():
	movable_vertices[-1].get_node("IN").points[1] = movable_vertices[-1].init_pos_in
	movable_vertices[-1].get_node("OUT").points[1] = movable_vertices[-1].init_pos_out
