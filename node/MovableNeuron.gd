extends KinematicBody2D

# set-getter
var location setget set_location
var type = "mov" setget , get_type
# parameter
var n = 3
var init_points = [Vector2.ZERO, Vector2.ZERO]
var cm2pix = 4 # get transform relation
onready var path := [[$Link_IN, $Link_IN/Cursor],[$Link_OUT,$Link_OUT/Cursor]]
var connected = [false,false] setget set_connected
# init collision parameter
var velocity = Vector2.ZERO

func get_type():
	return type

func init_location():
	location = [position]
	location += [path[0][1].global_position]
	location += [path[1][1].global_position]
	# save init relative points
	init_points[0] = path[0][1].position
	init_points[1] = path[1][1].position

func _physics_process(_delta):
	# to improve (bonus effect)
	"""
	velocity = position.direction_to(location[0])
	var collision = move_and_collide(velocity * delta)
	if collision != null :
		print(collision)
		init_location()
	update()
	"""
	pass

func set_location(values):
	# move neuron
	if values[1] == 0 :
		# update path
		location[0] = values[0]
		for i in range(path.size()) :
			if connected[i] :
				path[i][0].points[1] += (position - values[0])*cm2pix
				path[i][1].position = path[i][0].points[1]
			else :
				location[i+1] = values[0] + path[i][1].position / cm2pix
		# change position
		position = values[0]
	# move clips
	else : 
		if connected[values[1]-1] :
			pass
		else :
			location[values[1]] = values[0]
			path[values[1]-1][0].points[1] = (values[0] - location[0])*cm2pix
			path[values[1]-1][1].position = path[values[1]-1][0].points[1]

func set_connected(values):
	connected[values[1]] = values[0]
	# if not connection finded
	if not(values[0]) :
		path[values[1]][0].points[1] = init_points[values[1]]
		path[values[1]][1].position = path[values[1]][0].points[1]
		location[values[1]+1] = position + path[values[1]][1].position / cm2pix
