extends KinematicBody2D
class_name Mouse

func get_class(): return "Mouse"

var Mouse = load("res://Mouse.tscn")

signal mate_entered
signal kitty_entered

const OWN_BOUNDS = Vector2(32, 32)

var cooldown_min := 1.0
var cooldown_max := 8.0

export var gender := "" setget set_gender
export var grown_up := false setget set_grown
export var satisfied := false setget set_satisfied

var dir := Vector2()
var speed := 0.0
var state := ""
var mate : Node2D = null
var hunted := false

onready var kitties = $"../../Kitties"
onready var game = get_tree().get_current_scene()

func _ready():
	set_gender("m")
	set_grown(false)
	set_satisfied(false)
	start_roaming()
	
func _physics_process(delta):
	#if position.x < 0: position.x += global.BOUNDS.x
	#elif position.x > global.BOUNDS.x: position.x -= global.BOUNDS.x
	#if position.y < 0: position.y += global.BOUNDS.y
	#elif position.y > global.BOUNDS.y: position.y -= global.BOUNDS.y
	position = Vector2(
		clamp(position.x, 0, global.BOUNDS.x - OWN_BOUNDS.x),
		clamp(position.y, 0, global.BOUNDS.y - OWN_BOUNDS.y)
	)
	if state == "dating":
		if is_instance_valid(mate):
			dir = (mate.position - position).normalized()
		else:
			start_roaming()
	move_and_slide(dir * speed)
	#position += delta * dir * speed
	if dir.length() > 0:
		rotation_degrees = rad2deg(dir.angle())

func start_roaming(force = false):
	if state == "roaming" and not force: return
	if state != "roaming":
		state = "roaming"
		#print("start roaming")
	$Mating.visible = false
	dir = global.rand_dir()
	speed = rand_range(0, 256)
	for kitty in kitties.get_children():
		if dist(kitty) < 256:
			dir = (position - kitty.position).normalized()
			speed = 256
			break
	var timeout = rand_range(0.25, 0.5)
	yield(get_tree().create_timer(timeout), "timeout")
	if state != "roaming": return
	if (
		get_mice_count() < global.MAX_MICE and
		not satisfied and randf() > 0.125 and grown_up
	):
		var func_state = start_dating()
		if func_state != null:
			yield(get_tree().create_timer(5), "timeout")
			if func_state.is_valid():
				func_state.resume(true)
	else:
		start_roaming(true)

func start_dating():
	if state == "dating": return
	mate = null
	for m in get_other_mice():
		if m.gender == other_gender() and m.grown_up and dist(m) < 256:
			if m.wanna_date(self):
				mate = m
				state = "dating"
				#print("date found")
				break
	if mate == null:
		start_roaming(true)
	else:
		speed = 64
		$Mating.visible = true
		if not mate.get_node("Sprite/Area2D").overlaps_area($Area2D):
			var too_late = yield(mate, "mate_entered")
			if too_late and too_late == true:
				start_roaming(true)
				if mate != null and is_instance_valid(mate):
					mate.start_roaming(true)
				return
		#print("overlap")
		is_instance_valid(null)
		start_mating()

func wanna_date(other):
	if state == "roaming" and not satisfied:
		state = "dating"
		mate = other
		speed = 64
		#print("accept date")
		$Mating.visible = true
		return true
	return false

func start_mating(passive = false):
	if state == "mating": return
	#print("start mating")
	dir = Vector2()
	speed = 0
	state = "mating"
	$Particles2D.emitting = true
	mate.start_mating(true)
	yield(get_tree().create_timer(2), "timeout")
	if not passive:
		give_birth()
	mate = null
	$Mating.visible = false
	$Particles2D.emitting = false
	set_satisfied(true)
	start_roaming()

func give_birth():
	var mouse = Mouse.instance()
	get_parent().add_child(mouse)
	mouse.gender = "f" if randi() % 2 else "m"
	mouse.position = position
	game.mouse_count += 1
	if mouse.gender == "f": game.f_mouse_count += 1
	else: game.m_mouse_count += 1
	game.update_stats()

func set_gender(g):
	gender = g
	if gender == "m":
		modulate = Color.lightblue
	elif gender == "f":
		modulate = Color.pink

func set_grown(g):
	grown_up = g
	if grown_up:
		$Sprite.play("grown")
	else:
		$Sprite.play("baby")
		yield(get_tree().create_timer(10), "timeout")
		set_grown(true)

func set_satisfied(s):
	satisfied = s
	if satisfied:
		$Sprite.modulate *= 0.5
		yield(get_tree().create_timer(
			rand_range(cooldown_min, cooldown_max)), "timeout")
		set_satisfied(false)
	else:
		$Sprite.modulate *= 2.0

func other_gender():
	if gender == "m": return "f"
	return "m"

func get_mice_count():
	return get_parent().get_child_count()

func get_other_mice():
	var mice = get_parent().get_children()
	mice.erase(self)
	return mice

func dist(other : Node2D):
	return position.distance_to(other.position)

func _on_Area2D_area_entered(area):
	if is_instance_valid(mate) and area == mate.get_node("Sprite/Area2D"):
		emit_signal("mate_entered")
	if area.get_parent().get_class() == "Kitty":
		emit_signal("kitty_entered")
