extends SoulBehavior

const JUSTICE_PELLET := preload("res://pellets/justice_pellet/justice_pellet.tscn")

@export var face_direction : Util.Direction = Util.Direction.EAST
var degrees : float = 0

@export var shooting_cooldown : float = 0.1
var current_cooldown : float = 0

var holdingDuration : float = 0

func start() -> void:
	degrees = Util.ROTATION_DEGREES_FROM_DIR.get(face_direction - 90, -90)
	soul.heart.rotation_degrees = degrees
	soul.collision.rotation_degrees = degrees
	soul.grazer.rotation_degrees = degrees

func tick(delta : float) -> void:
	if !soul.active:
		return
	if Input.is_action_pressed("confirm"):
		holdingDuration += delta
	current_cooldown-=delta
	if holdingDuration > 0 && !Input.is_action_pressed("confirm") && current_cooldown <= 0:
		holdingDuration = 0
		shoot()
		current_cooldown = shooting_cooldown

func shoot() -> void:
	var newPellet : GenericPellet = JUSTICE_PELLET.instantiate()
	newPellet.velocity = Vector2(200, 0).rotated(rad_to_deg(degrees + 90))
	newPellet.z_index = soul.z_index
	newPellet.global_position = soul.global_position + Vector2(8, 0).rotated(rad_to_deg(degrees + 90)) * soul.scale.x
	soul.get_parent().add_child(newPellet)
