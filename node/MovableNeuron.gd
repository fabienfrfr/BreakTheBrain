extends RigidBody2D

var screen_size
var position_mouse
var d_ 

var absolut_position_in = Vector2.ZERO
var absolut_position_out = Vector2.ZERO
var relative_pos_in
var relative_pos_out
var d_in
var d_out
var cm2pix = 3.7795275591

var init_pos_in = Vector2.ZERO
var init_pos_out = Vector2.ZERO

var Biases # get by the GraphGen (to improve)
var Weight_in
var Weight_out

func _ready():
	screen_size = get_viewport_rect().size
	init_pos_in = $IN.get_point_position(1)
	init_pos_out = $OUT.get_point_position(1)
	Biases = 1.0
	Weight_in = 1.0
	Weight_out = 1.0

func _process(_delta):
	position_mouse = get_viewport().get_mouse_position()
	if Input.is_action_pressed("ui_accept"):
		d_ = position - position_mouse
		relative_pos_in = $IN.get_point_position(1)
		relative_pos_out = $OUT.get_point_position(1)
		absolut_position_in = position + relative_pos_in / cm2pix
		absolut_position_out = position + relative_pos_out / cm2pix
		d_in = absolut_position_in - position_mouse
		d_out = absolut_position_out - position_mouse
		if d_.length() < screen_size[0]/10 :
			position = position_mouse
			$IN.points[1] = (absolut_position_in - position)*cm2pix
			$OUT.points[1] = (absolut_position_out - position)*cm2pix
		elif d_in.length() < 25 :
			$IN.points[1] = -(position - position_mouse)*cm2pix
		elif d_out.length() < 25 :
			$OUT.points[1] = -(position - position_mouse)*cm2pix
