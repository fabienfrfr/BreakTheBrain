extends Line2D

export (Gradient) var grad

var pos := 0.0
var follows := []

onready var path := $TraceWave

var points_count
var min_x
var max_x
var min_y
var max_y

func _initialization(p_count, mn_x, mx_x, mn_y, mx_y):
	#save info
	min_x = mn_x
	max_x = mx_x
	min_y = mn_y
	max_y = mx_y
	points_count  = p_count
	# path construct
	clear_points()
	path.curve.clear_points()
	for n in range(points_count):
		path.curve.add_point(Vector2(min_x+n*(max_x-min_x)/(points_count-1),0))
	# construct 10 path-follow
	for i in 10 :
		var new_follow = PathFollow2D.new()
		path.add_child(new_follow)
		new_follow.unit_offset = float(i*0.02)
		follows.append(new_follow)

func update_path_and_point(predicted_values, time):
	clear_points()
	var v_predicted
	for n in range(points_count):
		v_predicted = Vector2(min_x+n*(max_x-min_x)/(points_count-1), min_y + (max_y-min_y)*predicted_values[n])
		path.curve.set_point_position(n, v_predicted)
		add_point(v_predicted) # to improve : get pathfollow global position (timer relative)
	# train effect
	for f in follows :
		f.unit_offset = wrapf(f.unit_offset + time, 0,1)
		#add_point(f.global_position)
		#print(f.global_position)
	# adding gradient effect
	#gradient.colors[0] = grad.interpolate(follows[0].unit_offset)
	#gradient.colors[1] = grad.interpolate(follows[-1].unit_offset)
