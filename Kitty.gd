extends Polygon2D

export var satisfied := false setget set_satisfied

var dir := Vector2()
var speed := 0.0
var state := ""

func _ready():
	start_roaming()

func start_roaming(force = false):
	if state == "roaming" and not force: return
	if state != "roaming":
		state = "roaming"
		print("cat start roaming")
	dir = global.rand_dir()
	speed = rand_range(0, 256)
	var timeout = rand_range(0.25, 2.0)
	yield(get_tree().create_timer(timeout), "timeout")
	if state != "roaming": return
	if not satisfied and randf() > 0.125:
		start_dating()
	else:
		start_roaming(true)

func set_satisfied(s):
	satisfied = s
	if satisfied:
		color *= 0.5
		yield(get_tree().create_timer(8), "timeout")
		set_satisfied(false)
	else:
		color *= 2.0
