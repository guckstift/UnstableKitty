extends Node

const BOUNDS := Vector2(800, 600)

func rand_pos(own_bounds = Vector2()):
	return Vector2(
		rand_range(0, BOUNDS.x - own_bounds.x),
		rand_range(0, BOUNDS.y - own_bounds.y))
	
func rand_dir():
	return Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
