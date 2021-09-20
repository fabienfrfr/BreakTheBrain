extends RigidBody2D

var Weight = {}
var Biaise

var min_biases_pos
var max_biases_pos

var In_signal = {}
var Out_signal = Array([])

var position_mouse
var relative_pos_cursor
var absolut_position_cursor
var d_
var new_position_cursor
var cm2pix = 3.7795275591

var offset

func _ready():
	min_biases_pos = $Biases.points[0].y
	max_biases_pos = $Biases.points[1].y
	# middle position of biases cursor
	$Biases.points[1].y = (min_biases_pos + max_biases_pos)/2
	offset = 0.5

func collect_info():
	pass

func _process(_delta):
	position_mouse = get_viewport().get_mouse_position()
	if Input.is_action_pressed("ui_accept"):
		relative_pos_cursor = $Biases.get_point_position(1)
		absolut_position_cursor = position + relative_pos_cursor / cm2pix
		d_ = absolut_position_cursor - position_mouse
		if d_.length() < 15 :
			new_position_cursor = -(position.y - position_mouse.y)*cm2pix
			$Biases.points[1].y = clamp(new_position_cursor, max_biases_pos, min_biases_pos)
			offset = abs(($Biases.points[1].y - min_biases_pos)/(max_biases_pos-min_biases_pos))
