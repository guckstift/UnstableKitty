extends Node2D

var Mouse = load("res://Mouse.tscn")
var Kitty = load("res://Kitty.tscn")

var mode = null
var kitty_count := 1
var mouse_count := 0
var f_mouse_count := 0
var m_mouse_count := 0

var phase := "intro"
var clock := 0.0

func _enter_tree():
	randomize()

func _input(event):
	if event is InputEventMouseMotion:
		if is_instance_valid(mode):
			mode.position = event.position
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			mode = null

func _ready():
	return
	spawn_rand_mouse()
	spawn_rand_mouse()
	spawn_rand_mouse()
	spawn_rand_mouse()
	while true:
		spawn_rand_mouse()
		$Timer.wait_time = 15
		$Timer.one_shot = false
		$Timer.start()
		yield($Timer, "timeout")

func _process(delta):
	if phase == "warmup":
		clock -= delta
		if clock <= 0.0:
			start_test_phase()
	elif phase == "test":
		clock -= delta
		if clock <= 0.0:
			test_ended()
		elif mouse_count >= global.MAX_MICE:
			mouse_overpopulation()
		elif mouse_count == 0:
			mouse_extinction()
	update_info_label()

func test_ended():
	var end_label = $CanvasLayer/EndLabel
	end_label.visible = true
	end_label.bbcode_text = "[center][wave][color=#0f0]Test successful"
	end_label.modulate = Color.white
	phase = "success"

func mouse_overpopulation():
	var end_label = $CanvasLayer/EndLabel
	end_label.visible = true
	end_label.bbcode_text = "[center][shake rate=50 level=60]Mouse Overpopulation"
	end_label.modulate = Color.red
	phase = "over"

func mouse_extinction():
	var end_label = $CanvasLayer/EndLabel
	end_label.visible = true
	end_label.bbcode_text = "[center][tornado radius=9 freq=1]Mice Extinction"
	end_label.modulate = Color.gray
	phase = "over"

func spawn_rand_mouse():
	var mouse = Mouse.instance()
	$Mice.add_child(mouse)
	mouse.gender = "f" if randi() % 2 else "m"
	mouse.grown_up = true
	mouse.position = global.rand_pos()

func update_stats():
	var text = ""
	if kitty_count > 0:
		text += "Kitties: " + str(kitty_count)
	if mouse_count > 0:
		text += "  Mice: " + str(mouse_count) + " ("
		if f_mouse_count > 0:
			text += " female: " + str(f_mouse_count)
		if m_mouse_count > 0:
			text += " male: " + str(m_mouse_count)
		text += ")"
	$CanvasLayer/StatsLabel.bbcode_text = text
	var mouse_ratio = float(mouse_count) / global.MAX_MICE
	$CanvasLayer/ColorRect.visible = true
	var inner_rect = $CanvasLayer/ColorRect/ColorRect
	inner_rect.color = lerp(Color.green, Color.red, mouse_ratio)
	inner_rect.anchor_left = 1.0 - mouse_ratio

func restart():
	phase = "intro"
	$CanvasLayer/CatButton.disabled = false
	$CanvasLayer/CatButton.modulate = Color.white
	$CanvasLayer/MouseGirlButton.disabled = false
	$CanvasLayer/MouseGirlButton.modulate = Color.white
	$CanvasLayer/MouseBoyButton.disabled = false
	$CanvasLayer/MouseBoyButton.modulate = Color.white

func start_warmup():
	if phase != "intro": return
	phase = "warmup"
	clock = global.WARM_UP + 1
	update_info_label()

func start_test_phase():
	phase = "test"
	clock = global.TEST_PHASE + 1
	$CanvasLayer/CatButton.disabled = true
	$CanvasLayer/CatButton.modulate = Color(1, 0.75, 0.75, 0.25)
	$CanvasLayer/MouseGirlButton.disabled = true
	$CanvasLayer/MouseGirlButton.modulate = Color(1, 0.75, 0.75, 0.25)
	$CanvasLayer/MouseBoyButton.disabled = true
	$CanvasLayer/MouseBoyButton.modulate = Color(1, 0.75, 0.75, 0.25)
	update_info_label()

func update_info_label():
	if phase == "warmup":
		var text := "Setup phase ends in: "
		text += str(int(clock)) + " seconds"
		$CanvasLayer/InfoLabel.text = text
		$CanvasLayer/InfoLabel.margin_top = 56
	elif phase == "test":
		var text := "Test phase ends in: "
		var secs = int(clock) % 60
		var mins = int(clock) / 60
		if mins > 0:
			text += str(mins) + " minutes "
		if secs > 0:
			text += str(secs) + " seconds"
		$CanvasLayer/InfoLabel.text = text
		$CanvasLayer/InfoLabel.margin_top = 720
	elif phase == "over":
		$CanvasLayer/InfoLabel.text = "Game Over!"
		$CanvasLayer/InfoLabel.modulate = Color.lightcoral
	elif phase == "success":
		$CanvasLayer/InfoLabel.text = "Success!"
		$CanvasLayer/InfoLabel.modulate = Color.lightgreen

func _on_CatButton_pressed():
	mode = Kitty.instance()
	$Kitties.add_child(mode)
	kitty_count += 1
	update_stats()
	start_warmup()

func _on_MouseButton_pressed():
	mode = Mouse.instance()
	$Mice.add_child(mode)
	mode.gender = "f"
	mouse_count += 1
	f_mouse_count += 1
	update_stats()
	start_warmup()

func _on_MouseBoyButton_pressed():
	mode = Mouse.instance()
	$Mice.add_child(mode)
	mode.gender = "m"
	mouse_count += 1
	m_mouse_count += 1
	update_stats()
	start_warmup()
