extends SoulMove

@export var gravity := Vector2(0, 1)
@export var jump_speed_multiplier : float = 1.0
@export var max_air_time : float = 0.2
@export_enum("X", "Y") var movement_axis : int

var current_air_time : float = 0

func start() -> void:
	soul.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED

func physics_tick(delta:float) -> void:
	super.physics_tick(delta)
	if !soul.is_on_floor():
		if current_air_time > 0.0:
			current_air_time -= delta
	else:
		current_air_time = max_air_time

func getInput() -> Vector2:
	var originalMovement : Vector2 = super.getInput()
	if movement_axis == 0:
		originalMovement.y = 0
	else:
		originalMovement.x = 0
	if should_ascend():
		originalMovement += -gravity * jump_speed_multiplier
	elif !soul.is_on_floor():
		originalMovement += gravity
	return originalMovement

func should_ascend() -> bool:
	return Input.is_action_pressed("up") && current_air_time > 0.0
