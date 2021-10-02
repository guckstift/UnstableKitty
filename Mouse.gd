extends Polygon2D
class_name Mouse

var Mouse = load("res://Mouse.tscn")

signal mate_entered

const OWN_BOUNDS = Vector2(32, 32)

export var gender := "" setget set_gender
export var grown_up := false setget set_grown
export var satisfied := false setget set_satisfied

var dir := Vector2()
var speed := 0.0
var state := ""
var mate : Node2D = null

func _ready():
	set_gender("m")
	set_grown(false)
	set_satisfied(false)
	start_roaming()
	
func _physics_process(delta):
	position = Vector2(
		clamp(position.x, 0, global.BOUNDS.x - OWN_BOUNDS.x),
		clamp(position.y, 0, global.BOUNDS.y - OWN_BOUNDS.y)
	)
	if state == "dating":
		dir = (mate.position - position).normalized()
	position += delta * dir * speed

func start_roaming(force = false):
	if state == "roaming" and not force: return
	if state != "roaming":
		state = "roaming"
		print("start roaming")
	dir = global.rand_dir()
	speed = rand_range(0, 256)
	var timeout = rand_range(0.25, 2.0)
	yield(get_tree().create_timer(timeout), "timeout")
	if state != "roaming": return
	if not satisfied and randf() > 0.125 and grown_up:
		start_dating()
	else:
		start_roaming(true)

func start_dating():
	if state == "dating": return
	for m in get_other_mice():
		if m.gender == other_gender() and m.grown_up and dist(m) < 256:
			if m.wanna_date(self):
				mate = m
				state = "dating"
				print("date found")
				break
	if mate == null:
		start_roaming(true)
	else:
		speed = 64
		yield(mate, "mate_entered")
		print("overlap")
		start_mating()

func wanna_date(other):
	if state == "roaming" and not satisfied:
		state = "dating"
		mate = other
		speed = 64
		print("accept date")
		return true
	return false

func start_mating(passive = false):
	if state == "mating": return
	print("start mating")
	dir = Vector2()
	speed = 0
	state = "mating"
	mate.start_mating(true)
	yield(get_tree().create_timer(2), "timeout")
	if not passive:
		give_birth()
	mate = null
	set_satisfied(true)
	start_roaming()

func give_birth():
	var mouse = Mouse.instance()
	get_parent().add_child(mouse)
	mouse.gender = "f" if randi() % 2 else "m"
	mouse.position = position

func set_gender(g):
	gender = g
	if gender == "m":
		color = Color.lightblue
	elif gender == "f":
		color = Color.pink

func set_grown(g):
	grown_up = g
	if grown_up:
		scale = Vector2(1, 1)
	else:
		scale = Vector2(0.5, 0.5)
		yield(get_tree().create_timer(8), "timeout")
		set_grown(true)

func set_satisfied(s):
	satisfied = s
	if satisfied:
		color *= 0.5
		yield(get_tree().create_timer(8), "timeout")
		set_satisfied(false)
	else:
		color *= 2.0

func other_gender():
	if gender == "m": return "f"
	return "m"

func get_other_mice():
	var mice = get_parent().get_children()
	mice.erase(self)
	return mice

func dist(other : Node2D):
	return position.distance_to(other.position)

func _on_Area2D_area_entered(area):
	if mate != null and area == mate.get_node("Area2D"):
		emit_signal("mate_entered")
