extends Polygon2D
class_name Mouse

const BOUNDS := Vector2(1024, 768)
const OWN_BOUNDS = Vector2(32, 32)

export var gender := "" setget set_gender

var dir := Vector2()
var speed := 0.0
var clock := 0.0
var timeout := 0.0
var state := ""
var mate :Node2D= null

func _ready():
	set_gender("m")
	start_roaming()
	
func _physics_process(delta):
	clock += delta
	position = Vector2(
		clamp(position.x, 0, BOUNDS.x - OWN_BOUNDS.x),
		clamp(position.y, 0, BOUNDS.y - OWN_BOUNDS.y)
	)
	if state == "roaming":
		if clock > timeout:
			clock = 0
			if randf() > 0.5:
				start_dating()
			else:
				dir = rand_dir()
				timeout = rand_range(0.25, 2.0)
				speed = rand_range(0, 256)
	elif state == "dating":
		goto(mate)
		if mate.get_node("Area2D").overlaps_area($Area2D):
			print("overlap")
			
	position += delta * dir * speed

func start_roaming():
	if state == "roaming": return
	clock = 0
	dir = rand_dir()
	timeout = rand_range(0.25, 2.0)
	speed = rand_range(0, 256)
	state = "roaming"
	print("start roaming")

func start_dating():
	for m in get_other_mice():
		if m.gender == other_gender() and dist(m) < 256:
			if m.wanna_date(self):
				mate = m
				state = "dating"
				print("date found")
				break
	if mate == null:
		start_roaming()

func wanna_date(other):
	if state == "roaming":
		state = "dating"
		mate = other
		print("accept date")
		return true
	return false

func goto(obj : Node2D):
	dir = (obj.position - position).normalized()
	speed = 64

func set_gender(g):
	gender = g
	if gender == "m":
		color = Color.lightblue
	elif gender == "f":
		color = Color.pink

func other_gender():
	if gender == "m": return "f"
	return "m"

func get_other_mice():
	var mice = get_parent().get_children()
	mice.erase(self)
	return mice

func rand_dir():
	return Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()

func dist(other : Node2D):
	return position.distance_to(other.position)
