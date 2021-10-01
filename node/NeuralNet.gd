extends Node

var solution_matrix

# dot product matrix*vector
func dot_mv(mat,vect):
	var c = []
	for i in range(vect.size()):
		var l = 0
		for j in range(vect.size()):
			l += mat[i][j]*vect[j]
		c += [l]
	return c

# dot product vector*matrix
func dot_vm(vect,mat):
	var l = []
	for i in range(mat[0].size()):
		var c = 0
		for j in range(vect.size()):
			c += vect[j]*mat[j][i]
		l += [c]
	return l

func Heaviside(x_list):
	var x_new = []
	for x in x_list :
		x_new += [int(x>0)]
	return x_new

func ReLU(x_list):
	var x_new = []
	for x in x_list :
		if x > 0 :
			x_new += [x]
		else :
			x_new += [0]
	return x_new

# algorithm
func graph2computation(input_x,adj_matrice):
	## Initialisation
	# output vector construction (1 if not calculed : biaise)
	var s = [input_x]
	for _i in range(adj_matrice.size()-1):
		var o = []
		for _j in range(input_x.size()):
			o += [1]
		s += [o]
	# calculate vector (1 if uncalculed, 0 else)
	var calc_v = []
	for _i in range(adj_matrice.size()):
		calc_v += [1]
	# connection matrice (1 if adj matrix != 0)
	var connect_mat = []
	for l in adj_matrice :
		var line = []
		for c in l :
			line += [int(c!=0)]
		connect_mat += [line]
	## Calculate output
	var calc_idx
	var rslt_v
	var wproduct
	for i in range(adj_matrice.size()):
		# find next line to calculate (to calc if 1, 0 if calculated, uncalculable now otherwise)
		rslt_v = dot_mv(connect_mat,calc_v)
		calc_idx = rslt_v.find(1)
		# update calculate vector
		calc_v[calc_idx] = 0
		# calculate linear combinaison
		wproduct =  dot_vm(adj_matrice[calc_idx], s)
		# update output
		if calc_idx == 0 :
			s[calc_idx] = wproduct
		elif i == adj_matrice.size() - 1 :
			s[calc_idx] = ReLU(wproduct)
		else :
			s[calc_idx] = Heaviside(wproduct)
	return normalization(s[-1]) # only fixed output

func normalization(fct) :
	var normed = []
	if fct.max() != 0 :
		for f in fct :
			normed += [f/fct.max()]
	else :
		normed = fct
	return normed

func solution_generator(input, param, graph) : #nb_c, position_node, init_adj_matrix, movable_neuron):
	solution_matrix = graph["matrix"].duplicate(true)
	# generate connection of movable neuron
	var nb_connect_in = param["nb_i"] + param["nb_fix"]
	var in_idx
	var in_pos
	var out_idx_list
	var out_idx
	# fix part :
	for l in range(param["nb_i"], nb_connect_in) :
		for c in range(solution_matrix[l].size()) :
			if solution_matrix[l][c] != 0 :
				solution_matrix[l][c] += 0.85*(randf()-0.5)
	# out part (to adapt if 2d output)
	for c in range(solution_matrix[-1].size()):
		if solution_matrix[-1][c] != 0 :
			solution_matrix[-1][c] += 0.5*(randf()-0.5)
	# mov part : input then output
	for i in range(param["nb_mov"]):
		in_idx = randi() % nb_connect_in
		in_pos = graph['position'][in_idx]
		out_idx_list = []
		for j in range(graph['position'].size()) :
			if graph['position'][j] > in_pos and graph['type'][j] != "mov" :
				out_idx_list += [j]
		out_idx = out_idx_list[randi() % out_idx_list.size()]
		# add in solution matrix
		solution_matrix[nb_connect_in+i][in_idx] = graph["w_mov"][i][0] # in
		solution_matrix[out_idx][nb_connect_in+i] = graph["w_mov"][i][1] # out
	# return solution
	return graph2computation(input,solution_matrix)
