extends SoulBehavior
class_name SoulMove

@export var normalized_movement := false
@export var speed := 4.0 * 30.0 # 4 pixels per frame
@export var slow_multiplier := 0.5

func start() -> void:
	soul.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func physics_tick(delta : float) -> void:
	if !soul.active:
		return
	var input := getInput()
	print(input)
	if normalized_movement:
		input = input.normalized()
	
	soul.velocity = Vector2.ZERO
	if input != Vector2.ZERO:
		soul.velocity = speed * input
		if Input.is_action_pressed("cancel"):
			soul.velocity *= slow_multiplier
	soul.move_and_slide()

func getInput() -> Vector2:
	return Vector2(
		int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")),
		int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	)
