extends Node

var position_mouse
var d_
var screen_size
var x_offset
var delta_x
var delta_y 

func _ready():
	$Line.clear_points()

func add_link(vectA,vectB):
	$Line.add_point(vectA)
	$Line.add_point(vectB)
	$Line/WeightPath.curve.set_point_position(0, vectA)
	$Line/WeightPath.curve.set_point_position(1, vectB)
	$Line/WeightPath/WeighLvlFollow.unit_offset = 0.5 # necessary for update
	$Line/WeightPath/WeighLvlFollow.show()

func _process(_delta):
	position_mouse = get_viewport().get_mouse_position()
	if Input.is_action_pressed("ui_accept"):
		d_ = $Line/WeightPath/WeighLvlFollow.position - position_mouse
		if d_.length() < 50 :
			delta_y = (position_mouse.x - $Line/WeightPath.curve.get_point_position(0).x)
			delta_x = ($Line/WeightPath.curve.get_point_position(1).x - $Line/WeightPath.curve.get_point_position(0).x)
			x_offset = delta_y/delta_x
			$Line/WeightPath/WeighLvlFollow.unit_offset = abs(x_offset)
			$Line/WeightPath/WeighLvlFollow.show()
