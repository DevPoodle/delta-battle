extends SoulMove

@export var gravity := Vector2(0, 1)
@export var jump_speed_multiplier : float = 1.2
@export var max_air_time : float = 0.3

var current_air_time : float = 0

func start() -> void:
	set_gravity_direction(Util.Direction.NORTH)
	soul.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED

func tick(delta:float) -> void:
	super.tick(delta)
	if !soul.is_on_floor():
		if current_air_time > 0.0:
			current_air_time -= delta
	else:
		current_air_time = max_air_time

func apply_speed(input : Vector2) -> Vector2:
	var sup := super.apply_speed(input)
	if should_ascend():
		sup += -gravity * speed * jump_speed_multiplier
	elif !soul.is_on_floor():
		sup += gravity * speed
	return sup

func should_ascend() -> bool:
	return Input.is_action_pressed("up") && current_air_time > 0.0

func set_gravity_direction(dir : Util.Direction, multiplier : float = 1.0) -> void:
	var dir_to_axis := {
		Util.Direction.NORTH: MoveAxis.X,
		Util.Direction.SOUTH: MoveAxis.X,
		Util.Direction.EAST: MoveAxis.Y,
		Util.Direction.WEST: MoveAxis.Y
	}
	set_axis(dir_to_axis.get(dir, MoveAxis.X))
	gravity = Vector2(1, 0).rotated(deg_to_rad(Util.ROTATION_DEGREES_FROM_DIR.get(dir))) * multiplier
	soul.up_direction = -gravity
	soul.visually_rotate(Util.ROTATION_DEGREES_FROM_DIR.get(dir) - 90)
