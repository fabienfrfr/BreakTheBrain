extends Node

var o = Array([[],[],[]])
var uncalculed = [1,2]
var linear_app

func Heaviside(x_list):
	var x_new = []
	for x in x_list :
		x_new += [int(x>0)]
	return x_new
	
func line_computation(idx, mat):
	var affin = []
	var sum = []
	var b = 0
	var Line
	for i in range(mat[idx]):
		if i == idx :
			b = mat[idx][i]
		else :
			if mat[idx][i] != 0 :
				for f in o[i]:
					affin += [mat[idx][i]*f]
				sum += [affin]
				affin = []
	for s in sum :
		Line = s + b
	return Line

func computational_graph(input,adj_matrice):
	var boolean_test = []
	for i in range(adj_matrice.size()-1):
		if i == 0 :
			o[0] =  input
		else :
			for j in range(1,adj_matrice.size()-1):
				for c in uncalculed :
					for l in range(adj_matrice.size()) :
						if adj_matrice[j][c] != 0 :
							boolean_test += ["not"]
				if "not" in boolean_test :
					pass
				else :
					linear_app = line_computation(j, adj_matrice)
					o[j] = Heaviside(linear_app)
					uncalculed.remove(uncalculed.find(j))

