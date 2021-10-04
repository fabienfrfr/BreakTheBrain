extends Node

## module
const GraphGen = preload("node/GraphGen.gd")
const NeuralNet = preload("node/NeuralNet.gd")

## variable
# global
var screen_size
# graph variable
var gg
var graph_param = {"nb_i": 1, "nb_out": 1, "nb_fix": 1, "nb_mov": 0}
var graph_var
var graph_init
# curve and network variable
var c_prm = {'nb_pts':200, 'delta_x':8,'input':[]}
var curve_var = {'target':[], 'predict':[]}
var nn
var time = 0
var error

## start party
func _ready():
	# initialisation
	graph_param["nb_fix"] = $HUD.gp["nb_fix"]
	graph_param["nb_mov"] = $HUD.gp["nb_mov"]
	screen_size = Vector2(800,600) #get_viewport().size
	randomize()
	# generate graph of network
	gg = GraphGen.new()
	graph_var = gg.construct_random_netgraph(graph_param, screen_size)
	graph_init = graph_var.duplicate(true) # for reset
	# game controler and display
	$GamePlay.game_setting(graph_var)
	# curve initialization
	$Predicted._initialization(screen_size, c_prm['nb_pts'])
	$TargetY._initialization(screen_size, c_prm['nb_pts'])
	# linear input generator
	c_prm['input'] = []
	for n in range(c_prm['nb_pts']) :
		c_prm['input'] += [c_prm['delta_x']*(float(n)/(c_prm['nb_pts']-1))-c_prm['delta_x']/2]
	# networks calculation
	nn =  NeuralNet.new()
	curve_var['predict'] = nn.graph2computation(c_prm['input'], graph_var["matrix"])
	curve_var['target'] = nn.solution_generator(c_prm['input'], graph_param, graph_var)
	# free memory
	gg.queue_free()
	# no success in start
	error = error_abs()
	if error < 0.1 :
		nn.queue_free()
		# restart
		_ready()
	# flip-flop
	$HUD.ff = 0

## during party
func _process(delta):
	# collect new parameter
	graph_var = $GamePlay.graph_var
	# update
	curve_var['predict'] = nn.graph2computation(c_prm['input'], graph_var["matrix"])
	# plot
	time += delta
	$Predicted.update_path_and_point(curve_var['predict'], 0.15, wrapf(time, 0,1))
	$TargetY.update_path_and_point(curve_var['target'], 0.25, wrapf(time, 0,1))
	# error calculation
	error = error_abs()
	# update text score and check success
	$HUD.error_event(error)

## error
func error_abs():
	error = 0
	for n in range(c_prm['nb_pts']) :
		error += abs(curve_var['target'][n] - curve_var['predict'][n])
	return error/c_prm['nb_pts']

## reset
func _on_HUD_reset():
	# less than 3-tries
	$GamePlay.game_setting(graph_init)

## next lvl
func _next_lvl():
	# free memory
	nn.queue_free()
	# restart
	_ready()
