extends Node

var position_mouse
var d_
var screen_size
var offset = 0.5
var delta_x
var delta_m
var scalar_projection

func _ready():
	$Line.clear_points()

func add_link(vectA,vectB):
	$Line.add_point(vectA)
	$Line.add_point(vectB)
	$Line/Cursor.position = vectA.linear_interpolate(vectB, offset)

func _process(_delta):
	position_mouse = get_viewport().get_mouse_position()
	if Input.is_action_pressed("ui_accept"):
		d_ = $Line/Cursor.position - position_mouse
		if d_.length() < 50 :
			delta_m = (position_mouse - $Line.points[0])
			delta_x = ($Line.points[1] - $Line.points[0])
			scalar_projection = delta_m.dot(delta_x)/delta_x.length()
			offset = clamp(scalar_projection/delta_x.length(), 0.1,0.9) 
			$Line/Cursor.position = $Line.points[0].linear_interpolate($Line.points[1], offset)
