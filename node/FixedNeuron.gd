extends Node2D

# setter
var target = Vector2.ZERO setget set_mvt
# getter
var type = "fix" setget , get_type

### variable
var biases_pos = {'min':0, 'max':0, 'offset':0, "delta":0}
var cm2pix = 4
var new_position

### function
func _ready():
	# initialize biase extremum
	biases_pos['min'] = $Biases.points[0].y
	biases_pos['max'] = $Biases.points[1].y
	# middle position of biases cursor
	$Biases.points[1].y = (biases_pos['min'] + biases_pos['max'])/2
	biases_pos['offset'] = 0.5
	biases_pos["delta"] = biases_pos['max'] - biases_pos['min']

func set_mvt(value):
	new_position = -0.1*(position.y - value.y)*cm2pix
	$Biases.points[1].y = clamp(new_position, biases_pos['max'], biases_pos['min'])
	biases_pos['offset'] = abs(($Biases.points[1].y - biases_pos['min'])/(biases_pos["delta"]))

func get_type():
	return type
