extends Node

func _ready():
	$Line.clear_points()

func add_link(vectA,vectB):
	$Line.add_point(vectA)
	$Line.add_point(vectB) 
