extends CanvasLayer

signal reset_link

func _on_ResetButton_pressed():
	emit_signal("reset_link")
