extends CanvasLayer

signal reset_link

# solve the problem in 10 second
var time = 10
# levelup
var nb_vertice

func _on_ResetButton_pressed():
	emit_signal("reset_link")

func _on_MessageTimer_timeout():
	yield($MessageTimer, "timeout")
	$Message.text = "Go !"
	$Message.show()
	yield($MessageTimer, "timeout")
	$Message.hide()

func _level_p_gen(nb,score):
	nb_vertice = nb + score
	return [int(nb_vertice/2), nb_vertice % int(nb_vertice/2) + 1]
