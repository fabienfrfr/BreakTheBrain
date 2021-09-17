extends CanvasLayer

signal reset_link

# solve the problem in 10 second
var time = 10

func _on_ResetButton_pressed():
	emit_signal("reset_link")

func _on_MessageTimer_timeout():
	yield($MessageTimer, "timeout")
	$Message.text = "Get Ready ?"
	$Message.show()
	yield($MessageTimer, "timeout")
	$Message.text = "Go !"
	$Message.show()
	yield($MessageTimer, "timeout")
	$Message.hide()

