extends Line2D

# instanciation
export (Gradient) var grad
onready var path := $TraceWave
onready var line := $Calk
# Train effect
var pos := 0.0
var follows := []
# parameter
var info = {'nb_points':0,'x':[],'y':[]}
var r = [0,0]

func _initialization(size, nb):
	# calculate
	info['nb_points'] =  nb
	info['x'] = [size[0]*0.1, size[0]*0.9]
	info['y'] = [size[1]*0.95, size[1]*0.85]
	# path construct
	clear_points()
	path.curve.clear_points()
	line.clear_points()
	for n in range(nb):
		r[0] = info['x'][0]+n*(info['x'][1]-info['x'][0])/(nb-1)
		path.curve.add_point(Vector2(r[0],info['y'][0]))

func update_path_and_point(values, stpi, percent):
	clear_points()
	line.clear_points()
	# train-like effect
	var step = [clamp(percent-stpi, 0, 1)*info['nb_points'], info['nb_points']*percent]
	for n in range(info['nb_points']):
		r[0] = info['x'][0] + (info['x'][1]-info['x'][0])/(info['nb_points']-1)*n
		r[1] = info['y'][0] + (info['y'][1]-info['y'][0])*values[n]
		if n > int(step[0]) and n < int(step[1]) :
			path.curve.set_point_position(n, Vector2(r[0], r[1]))
			add_point(Vector2(r[0], r[1]))
		line.add_point(Vector2(r[0], r[1]))
