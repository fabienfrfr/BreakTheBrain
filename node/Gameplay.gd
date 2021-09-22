extends Node2D

var dragging = false
var selected
var position_mouse

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT :
		if event.is_pressed():
			position_mouse = get_viewport().get_mouse_position()
			print(position_mouse)
