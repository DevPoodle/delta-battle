extends SoulBehavior

const SHIELD = preload("res://soul/behaviors/behavior_assets/shielding/shield.tscn")

@export var shield_scale : float = 1.0

var shield : Shield
var currentDirection : Direction = Direction.NORTH
var currentRotation : float = -90

var turning : bool = false

func start() -> void:
	create_shield()
	rotate_shield(currentRotation)

func _unhandled_input(_event: InputEvent) -> void:
	if !soul.active || turning:
		return
	var direction : Vector2 = Input.get_vector("left", "right", "up", "down")
	if direction == Vector2.ZERO:
		return
	
	#var newDirection : Direction = Direction.from_vector(direction)
	#if newDirection == currentDirection.left():
		#rotate_shield(90)
	#elif newDirection == currentDirection.right():
		#rotate_shield(-90)
	#elif newDirection == currentDirection.opposite():
		#rotate_shield(180)
	#currentDirection = newDirection
	
	if direction == Vector2.UP:
		if currentDirection == Direction.EAST:
			rotate_shield(-90)
		elif currentDirection == Direction.WEST:
			rotate_shield(90)
		elif currentDirection == Direction.SOUTH:
			rotate_shield(180)
		currentDirection = Direction.NORTH
	elif direction == Vector2.DOWN:
		if currentDirection == Direction.EAST:
			rotate_shield(90)
		elif currentDirection == Direction.WEST:
			rotate_shield(-90)
		elif currentDirection == Direction.NORTH:
			rotate_shield(180)
		currentDirection = Direction.SOUTH
	elif direction == Vector2.RIGHT:
		if currentDirection == Direction.NORTH:
			rotate_shield(90)
		elif currentDirection == Direction.SOUTH:
			rotate_shield(-90)
		elif currentDirection == Direction.WEST:
			rotate_shield(180)
		currentDirection = Direction.EAST
	elif direction == Vector2.LEFT:
		if currentDirection == Direction.EAST:
			rotate_shield(180)
		elif currentDirection == Direction.NORTH:
			rotate_shield(-90)
		elif currentDirection == Direction.SOUTH:
			rotate_shield(90)
		currentDirection = Direction.WEST

func end() -> void:
	shield.queue_free()

func turn_start() -> void:
	shield.visible = true

func turn_end() -> void:
	shield.visible = false

func rotate_shield(degrees : float) -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	turning = true
	tween.tween_property(shield, "rotation_degrees", shield.rotation_degrees + degrees, 0.05)
	tween.tween_callback(func(): turning = false)
	shield.rotation_degrees = int(shield.rotation_degrees) % 360

func create_shield() -> void:
	var newShield : Shield = SHIELD.instantiate()
	newShield.scale *= shield_scale
	newShield.show_behind_parent = true
	soul.add_child(newShield)
	shield = newShield
