extends Node

### variable
var graph_var = {"size":0, "position":[], "type":[], "adj_list":[], "weight":[], "biases":[], "w_mov": []}
var grid = [3,3]
### screen taking (relative 2 absolute)
var l_ = {"xL":0.1, "xR":0.9, "yU":0.2, "yM":0.5, "dX":0.2, "dY":0.1, "xnd":1}
func layout_update(screen_size):
	l_["xL"] *= screen_size.x
	l_["xR"] *= screen_size.x
	l_["yU"] *= screen_size.y
	l_["yM"] *= screen_size.y
	l_["dX"] *= screen_size.x
	l_["dY"] *= screen_size.y
	l_["DX"] = screen_size.x-4*l_["xL"]

func node_generator(gp):
	# param graph_var["biases"]
	var dy_i = l_["dY"]/(gp['nb_i']+1)
	var dy_o = l_["dY"]/(gp['nb_out']+1)
	var dist
	# input
	for i in range(gp['nb_i']):
		graph_var["position"] += [Vector2(l_["xL"],l_["yM"]-i*dy_i)]
		graph_var["type"] += ['in']
		graph_var["adj_list"] += [[]]
		graph_var["weight"] += [[]]
		graph_var["biases"] += [1.0]
	# fix
	var grid_fix = []
	var idx_fix
	for xi in range(grid[0]):
		for yi in range(grid[1]):
			grid_fix += [Vector2(xi,yi)]
	for _i in range(gp['nb_fix']):
		# position
		idx_fix = randi() % grid_fix.size()
		var v = grid_fix[idx_fix]
		graph_var["position"] += [Vector2(3*l_["xL"]+v.x*(l_["DX"]/grid[0]),l_["yU"]+v.y*(l_["yM"]/grid[1]))]
		grid_fix.remove(idx_fix)
		# link
		dist = []
		for p in graph_var["position"] :
			dist += [(graph_var["position"][-1]-p)]
			if dist[-1].x <= 0 :
				dist[-1] = NAN # front or itself
			else : 
				dist[-1] = dist[-1].length()
		graph_var["type"] += ['fix']
		graph_var["adj_list"] += [[dist.find(dist.min())]]
		graph_var["weight"] += [[randf()-0.5]]
		graph_var["biases"] += [randf()-0.5]
	# movable
	for _i in range(gp['nb_mov']):
		graph_var["position"] += [Vector2.ZERO]
		graph_var["type"] += ['mov']
		graph_var["adj_list"] += [[]]
		graph_var["weight"] += [[]]
		graph_var["biases"] += [randf()-0.5]
		graph_var["w_mov"] += [[randf()-0.5,randf()-0.5]]
	# output
	for i in range(gp['nb_out']):
		graph_var["position"] += [Vector2(l_["xR"],l_["yM"]-i*dy_o)]
		graph_var["type"] += ['out']
		dist = []
		for p in graph_var["position"] :
			# forward propagation only (need to verify)
			if (graph_var["position"][-1]-p).x > 0 : 
				dist += [(graph_var["position"][-1]-p).length()]
			else :
				dist += [NAN]
		graph_var["adj_list"] += [[dist.find(dist.min())]]
		graph_var["weight"] += [[randf()-0.5]]
		graph_var["biases"] += [randf()-0.5]

func construct_random_netgraph(gp, screensize):
	# layout update
	layout_update(screensize)
	# nb_node
	for v in gp.values():
		graph_var["size"] += v
	# generate position and param (to improve)
	node_generator(gp)
	# construct matrix
	var adj_matrix = []
	var line = []
	# empty matrix
	for _i in range(graph_var["size"]):
		for _j in range(graph_var["size"]):
			line += [0]
		adj_matrix += [line]
		line = []
	# update matrix
	for i in range(graph_var["size"]):
		# add biases
		adj_matrix[i][i] = graph_var["biases"][i]
		# add weight
		for l in graph_var["adj_list"][i]:
			adj_matrix[i][l] = graph_var["weight"][i][0]
	graph_var["matrix"] = adj_matrix.duplicate(true)
	return graph_var
