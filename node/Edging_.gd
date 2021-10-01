extends Node2D

# getter
var type = "edge" setget , get_type
var location = Vector2.ZERO setget , get_cursor_location
# setter
var target setget set_mvt

# displacement variable
var delta_m
var delta_x
var scalar_projection
var offset

func construct_visual_link(vectA,vectB):
	# delete sketch
	$Line.clear_points()
	# add link
	$Line.add_point(vectA)
	$Line.add_point(vectB)
	# cursor and collision position
	$Cursor.position = vectA.linear_interpolate(vectB, 0.5)
	location = $Cursor.position

func set_mvt(value):
	# calculate distance
	delta_m = value - $Line.points[0]
	delta_x = $Line.points[1] - $Line.points[0]
	# offset by scalar product method
	scalar_projection = delta_m.dot(delta_x)/delta_x.length()
	offset = clamp(scalar_projection/delta_x.length(), 0.1,0.9)
	# update position
	$Cursor.position = $Line.points[0].linear_interpolate($Line.points[1], offset)
	location = $Cursor.position

func get_type():
	return type

func get_cursor_location():
	return location
