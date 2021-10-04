extends Node

const BOUNDS := Vector2(1024, 768)
const MAX_MICE := 150
const WARM_UP := 10
const TEST_PHASE := 60 * 2

func rand_pos(own_bounds = Vector2()):
	return Vector2(
		rand_range(0, BOUNDS.x - own_bounds.x),
		rand_range(0, BOUNDS.y - own_bounds.y))
	
func rand_dir():
	return Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
