extends SoulBehavior

const JUSTICE_PELLET := preload("res://pellets/justice_pellet/justice_pellet.tscn")


@export var face_direction : Util.Direction = Util.Direction.NORTH
var degrees : float = 0

@export_category("Bullet Properties")
@export var shooting_cooldown : float = 0.2
var current_cooldown : float = 0

@export var big_shot_holding_duration : float = 1.0
var holdingDuration : float = 0

func start() -> void:
	set_direction(face_direction)

func tick(delta : float) -> void:
	if !soul.active:
		if holdingDuration > 0:
			holdingDuration = 0
		return
	if Input.is_action_pressed("confirm"):
		holdingDuration += delta
	current_cooldown-=delta
	if holdingDuration > 0 && !Input.is_action_pressed("confirm") && current_cooldown <= 0:
		shoot(holdingDuration>big_shot_holding_duration)
		holdingDuration = 0
		current_cooldown = shooting_cooldown
	if holdingDuration >= big_shot_holding_duration:
		animateBigShottedness()


##Doesn't work. IDK why. It probably hates me.
func animateBigShottedness() -> void:
	var amount : float = absf(sin(Time.get_ticks_msec())) * 2
	soul.modulate = soul.get_base_color().lerp(Color.WHITE_SMOKE, amount)

func shoot(is_big_shot : bool = false) -> void:
	var newPellet : JusticePellet = JUSTICE_PELLET.instantiate()
	newPellet.velocity = Vector2(200, 0).rotated(deg_to_rad(degrees + 90))
	newPellet.z_index = soul.z_index
	newPellet.is_big_shot = is_big_shot
	newPellet.global_position = soul.global_position + Vector2(8, 0).rotated(deg_to_rad(degrees + 90)) * soul.scale.x
	soul.get_parent().add_child(newPellet)

func set_direction(dir : Util.Direction) -> void:
	face_direction = dir
	degrees = Util.ROTATION_DEGREES_FROM_DIR.get(face_direction, -90) + 90
	soul.visually_rotate(degrees)
	soul.grazer.rotation_degrees = degrees
