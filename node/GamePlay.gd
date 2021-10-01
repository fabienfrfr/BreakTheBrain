extends Node2D

# instanciation
export (PackedScene) var Edges
export (PackedScene) var FixedNeuron
export (PackedScene) var InputX
export (PackedScene) var MovableNeuron

# get (asynchrone)
var graph_var setget , get_graph
var matrix_buffer # connection included
## variable
# visual graph (vertice and edges)
var node_ = Array([])
var matrix_info = Array([])
var nb_edges = 0
# node detection
var node_idx = Array([])
var node_pos = Array([])
var node_type = Array([''])
# node interaction
var position_mouse = Vector2()
var node_dist = Array([])
var selected = Array([0])

# in _ready() of Main
func game_setting(graph):
	graph_var = graph.duplicate(true)
	matrix_buffer = graph_var['matrix'].duplicate(true)
	# (re)initialize
	for n in node_ :
		n.queue_free()
	nb_edges = 0
	node_ = Array([])
	matrix_info = Array([])
	# edging
	for i in range(graph['size']):
		var edge = []
		for l in graph['adj_list'][i] :
			# instance line
			edge = [Edges.instance()]
			add_child(edge[-1])
			# add edges
			edge[-1].construct_visual_link(graph['position'][l],graph['position'][i])
			# true if one edges input :
			matrix_info += [[l,i]]
		node_ += edge
		nb_edges += edge.size()
	# node positionning
	var loc_m = 0
	for i in range(graph['size']):
		if graph['type'][i] == "in" :
			node_ += [InputX.instance()]
			matrix_info += [i]
		elif graph['type'][i] == "out" or graph['type'][i] == "fix" :
			node_ += [FixedNeuron.instance()]
			matrix_info += [i]
		elif graph['type'][i] == "mov" :
			node_ += [MovableNeuron.instance()]
			matrix_info += [[i,loc_m],[i,loc_m],[i,loc_m]]
			loc_m += 1
		add_child(node_[-1])
		if graph['type'][i] != "mov" :
			node_[-1].position = graph['position'][i]
		else :
			$MovePath/SpawnLoc.offset = randi()
			node_[-1].position = $MovePath/SpawnLoc.position
			node_[-1].init_location()
			# change order in scene
			move_child(node_[-1], nb_edges+1)
	pass

# select unique node
func _process(_delta):
	if Input.is_action_pressed("ui_accept"):
		# get position of click
		position_mouse = get_viewport().get_mouse_position()
		# maintain selected
		if selected.max() == 0 :
			# (re)initialize
			node_idx = Array([])
			node_type = Array([])
			node_pos = Array([])
			node_dist = Array([])
			selected = Array([])
			# construct list of position (3 for mvt)
			for n in range(node_.size()) :
				if node_[n].type != "mov" :
					node_idx += [n]
					node_type += [node_[n].type]
					if node_type[-1] == "edge" :
						node_pos += [node_[n].location]
					else :
						node_pos += [node_[n].position]
				else : 
					for i in range(node_[n].n):
						node_idx += [n]
						node_type += [node_[n].type]
						node_pos += [node_[n].location[i]]
			# calculate distance
			for n in node_pos :
				node_dist += [(n-position_mouse).length()]
				selected += [0]
			# increase if movable (unpriority)
			if node_type[node_dist.find(node_dist.min())] == "mov" :
				node_dist[node_dist.find(node_dist.min())] += 10
			# detect selection
			if node_dist.min() < 25 :
				selected[node_dist.find(node_dist.min())] = 1
		else :
			if node_type[selected.find(1)] == "edge" :
				node_[node_idx[selected.find(1)]].target = position_mouse
				update_weight_matrix(node_, node_idx, selected.find(1), matrix_info)
			elif node_type[selected.find(1)] == "fix" :
				node_[node_idx[selected.find(1)]].target = position_mouse
				update_biase_matrix(node_, node_idx, selected.find(1), matrix_info)
			elif node_type[selected.find(1)] == "mov" :
				# find index
				node_[node_idx[selected.find(1)]].location = [position_mouse, find_idx_mov()]
				node_pos[selected.find(1)] = position_mouse
	else :
		node_dist = Array([])
		# apply movable clips operation
		if node_type[selected.find(1)] == "mov" :
			# find idx connect
			var idx_c = find_idx_mov()
			if idx_c != 0 :
				# check connection part
				for n in node_pos :
					node_dist += [(n-node_pos[selected.find(1)]).length()]
				while node_idx[node_dist.find(node_dist.min())] == node_idx[selected.find(1)] :
					node_dist[node_dist.find(node_dist.min())] = node_dist.max()
				# update test
				var idx_ = node_dist.find(node_dist.min())
				if (node_type[idx_] == "in" or node_type[idx_] == "fix") and node_dist.min() < 50 :
					node_[node_idx[selected.find(1)]].connected = [true, idx_c-1]
					update_connection_matrix(selected.find(1), matrix_info, idx_c, idx_)
				else :
					node_[node_idx[selected.find(1)]].connected = [false, idx_c-1]
		selected = Array([0])

# fix function
func update_biase_matrix(n, i, s, m):
	graph_var['matrix'][m[s]][m[s]] = matrix_buffer[m[s]][m[s]] + (n[i[s]].biases_pos["offset"] - 0.5)
# edges function
func update_weight_matrix(n,i,s,m):
	graph_var['matrix'][m[s][1]][m[s][0]] = matrix_buffer[m[s][1]][m[s][0]] + (n[i[s]].offset - 0.5)
# mov function
func find_idx_mov():
	for i in range(node_idx.size()) :
		if node_idx[i] == node_idx[selected.find(1)] :
			return(abs(i-selected.find(1)))
func update_connection_matrix(s,m,ic,im):
	var ordinal = m[s][1]
	var idx_mov = m[s][0]
	var idx_lnk = m[im]
	if ic - 1 == 0 :
		matrix_buffer[idx_mov][idx_lnk] = graph_var["w_mov"][ordinal][0] # in
		graph_var['matrix'][idx_mov][idx_lnk] = graph_var["w_mov"][ordinal][0]
	elif ic - 1 == 1 :
		matrix_buffer[idx_lnk][idx_mov] = graph_var["w_mov"][ordinal][1] # out
		graph_var['matrix'][idx_lnk][idx_mov] = graph_var["w_mov"][ordinal][1]

# general infos
func get_graph():
	return graph_var
