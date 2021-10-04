extends AnimatedSprite
class_name Kitty

const OWN_BOUNDS = Vector2(96, 48)

export var cooldown_min := 0.5
export var cooldown_max := 3.0

export var satisfied := false setget set_satisfied

var dir := Vector2()
var speed := 0.0
var state := ""
var victim : Node2D = null

func get_class(): return "Kitty"

func _ready():
	start_roaming()
	
func _physics_process(delta):
	position = Vector2(
		clamp(position.x, OWN_BOUNDS.x / 2, global.BOUNDS.x - OWN_BOUNDS.x / 2),
		clamp(position.y, OWN_BOUNDS.y / 2, global.BOUNDS.y - OWN_BOUNDS.y / 2)
	)
	if state == "hunting":
		dir = (victim.position - position).normalized()
	position += delta * dir * speed
	if dir.length() > 0:
		rotation_degrees = rad2deg(dir.angle())

func start_roaming(force = false):
	if state == "roaming" and not force: return
	if state != "roaming":
		state = "roaming"
		#print("cat start roaming")
	dir = global.rand_dir()
	speed = rand_range(0, 256)
	var timeout = rand_range(0.25, 2.0)
	yield(get_tree().create_timer(timeout), "timeout")
	if state != "roaming": return
	if not satisfied and randf() > 0.125:
		start_hunting()
	else:
		start_roaming(true)

func start_hunting():
	if state == "hunting": return
	victim = null
	for m in $"../../Mice".get_children():
		if dist(m) < 256 and m.hunted == false:
			victim = m
			victim.hunted = true
			state = "hunting"
			#print("victim found")
			break
	if victim == null:
		start_roaming(true)
	else:
		speed = 320
		if not victim.get_node("Sprite/Area2D").overlaps_area($Area2D):
			yield(victim, "kitty_entered")
		#print("catched")
		var game = get_tree().get_current_scene()
		game.mouse_count -= 1
		if victim.gender == "f": game.f_mouse_count -= 1
		else: game.m_mouse_count -= 1
		game.update_stats()
		victim.queue_free()
		set_satisfied(true)
		start_roaming()

func set_satisfied(s):
	satisfied = s
	if satisfied:
		modulate.a = 0.75
		yield(get_tree().create_timer(
			rand_range(cooldown_min, cooldown_max)), "timeout")
		set_satisfied(false)
	else:
		modulate.a = 1

func dist(other : Node2D):
	return position.distance_to(other.position)
