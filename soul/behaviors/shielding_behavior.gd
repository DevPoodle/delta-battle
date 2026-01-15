extends SoulBehavior

const SHIELD = preload("res://soul/behaviors/behavior_assets/shielding/shield.tscn")

@export var shield_scale : float = 1.0

var shield : Shield
var currentRotation : Vector2 = Vector2.UP

func start() -> void:
	create_shield()
	rotate_shield(currentRotation)

func _unhandled_input(event: InputEvent) -> void:
	if !soul.active:
		return
	if event.is_action_pressed("up"):
		rotate_shield(Vector2.UP)
	elif event.is_action_pressed("down"):
		rotate_shield(Vector2.DOWN)
	elif event.is_action_pressed("right"):
		rotate_shield(Vector2.RIGHT)
	elif event.is_action_pressed("left"):
		rotate_shield(Vector2.LEFT)


##WIP
##I couldn't get the animated rotation code to work how I wanted.
func rotate_shield(direction : Vector2) -> void:
	var direction_to_rotation : Dictionary[Vector2, int] = {
		Vector2.DOWN: 90,
		Vector2.UP: 270,
		Vector2.RIGHT: 0,
		Vector2.LEFT: 180
	}
	if direction_to_rotation.get(direction) % 360 == shield.rotation_degrees:
		return
	shield.rotation_degrees = direction_to_rotation.get(direction, 0)

func create_shield() -> void:
	var newShield : Shield = SHIELD.instantiate()
	newShield.scale *= shield_scale
	newShield.show_behind_parent = true
	soul.add_child(newShield)
	shield = newShield
