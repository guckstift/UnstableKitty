extends Node2D

var Mouse = load("res://Mouse.tscn")

func _enter_tree():
	randomize()
	
func _ready():
	spawn_rand_mouse()
	spawn_rand_mouse()
	return
	while true:
		spawn_rand_mouse()
		$Timer.wait_time = 15
		$Timer.one_shot = false
		$Timer.start()
		yield($Timer, "timeout")

func spawn_rand_mouse():
	var mouse = Mouse.instance()
	$Mice.add_child(mouse)
	mouse.gender = "f" if randi() % 2 else "m"
	mouse.grown_up = true
	mouse.position = global.rand_pos()
