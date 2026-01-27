extends SoulBehavior
class_name SoulMove

enum MoveAxis {BOTH, X, Y}

@export var normalized_movement := false
@export var speed := 4.0 * 30.0 # 4 pixels per frame
@export var slow_multiplier := 0.5
@export var current_axis : MoveAxis

func start() -> void:
	soul.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func physics_tick(_delta : float) -> void:
	if !soul.active:
		return
	var input := getInput()
	if normalized_movement:
		input = input.normalized()
	
	soul.velocity = Vector2.ZERO
	soul.velocity = apply_speed(input)
	soul.move_and_slide()

func getInput() -> Vector2:
	if !soul.active:
		return Vector2.ZERO
	var input :=Vector2(
		int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")),
		int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	)
	if current_axis != MoveAxis.BOTH:
		input.y = 0
	if current_axis == MoveAxis.Y:
		input.y = input.x
		input.x = 0
	return input

func apply_speed(input : Vector2) -> Vector2:
	var final_input := input
	final_input *= speed
	if Input.is_action_pressed("cancel"):
		final_input *= slow_multiplier
	return final_input

func set_axis(axis : MoveAxis) -> void:
	current_axis = axis
