extends Node

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

func heaviside(x_list):
	var x_new = []
	for x in x_list :
		x_new += [int(x>0)]
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
	for _i in range(adj_matrice.size()):
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
		else :
			s[calc_idx] = heaviside(wproduct)
	return s[-1] # only fixed output
