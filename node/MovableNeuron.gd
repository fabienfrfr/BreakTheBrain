extends RigidBody2D

var screen_size
var position_mouse
var d_ 

func _ready():
	screen_size = get_viewport_rect().size

func _process(_delta):
	position_mouse = get_viewport().get_mouse_position()
	if Input.is_action_pressed("ui_accept"):
		d_ = position - position_mouse
		if d_.length() < screen_size[0]/10 :
			position = position_mouse
