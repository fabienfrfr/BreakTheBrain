extends CanvasLayer

signal reset_link
signal next_lvl(scr)

# solve parameter
var time = 60
var trial = 3
# lvl parameter
var gp = {"nb_fix": 1, "nb_mov": 1}
var score = 0
var difficulty = 0
var ff = 0

func _on_ResetButton_pressed():
	trial -= 1
	if trial > 0 :
		time = 60
		# destroy node-edges safely
		get_tree().call_group("fix_group", "queue_free")
		get_tree().call_group("edge_group", "queue_free")
		get_tree().call_group("mov_group", "queue_free")
		get_tree().call_group("In_group", "queue_free")
		# signal to main
		emit_signal("reset_link")
	else :
		time = 0
		trial = 0
	$TrialRemain.text = str(trial)
	$TrialRemain.show()

func _on_MessageTimer_timeout():
	yield($MessageTimer, "timeout")
	$Message.text = "Go !"
	$Message.show()
	yield($MessageTimer, "timeout")
	$Message.hide()

func _on_Count_timeout():
	$Countdown.text = str(time)
	time -= 1
	if time < 0 :
		$Message.text = "Try Again !"
		$Message.show()
		time = 0
		yield($MessageTimer, "timeout")
		# restart
		gp["nb_fix"] = 1
		gp["nb_mov"] = 1
		_on_MessageTimer_timeout()
		time = 60
		trial = 3
		score = 0
		$Score.text = str(score)
		$TrialRemain.text = str(trial)
		# signal to main
		emit_signal("next_lvl")

func error_event(error):
	$Error_abs.text = str(int(100*(1-error))) + " %"
	if error < 0.01 and ff == 0 :
		# flip-flop
		ff = 1
		# brief message of success
		$Message.text = "Success !"
		$Message.show()
		yield($MessageTimer, "timeout")
		$Message.hide()
		# update score
		score += 1
		$Score.text = str(score)
		$Score.show()
		# update difficulty
		if score % 5 == 0 :
			difficulty += 1
			# update parameter
			if gp["nb_fix"] == gp["nb_mov"]:
				gp["nb_fix"] +=1
			else :
				gp["nb_mov"] += 1
			trial = 3
			$TrialRemain.text = str(trial)
		# update time
		time = 60
		# destroy node-edges safely
		get_tree().call_group("fix_group", "queue_free")
		get_tree().call_group("edge_group", "queue_free")
		get_tree().call_group("mov_group", "queue_free")
		get_tree().call_group("In_group", "queue_free")
		# signal to main
		emit_signal("next_lvl")
		yield($MessageTimer, "timeout")
		
