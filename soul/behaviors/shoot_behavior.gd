extends SoulBehavior

const JUSTICE_PELLET := preload("res://pellets/justice_pellet/justice_pellet.tscn")


@export var face_direction : Direction = Direction.NORTH
var degrees : float = 0

@export_category("Shooting Properties")
@export var shooting_cooldown : float = 0.2
@export var big_shot_holding_duration : float = 1.0
@export var shooting_enabled : bool = true

var current_cooldown : float = 0
var holdingDuration : float = 0

@export var bullets : Array[JusticePellet] = []

func start() -> void:
	set_direction(face_direction)

# Handles shooting
func tick(delta : float) -> void:
	if shooting_disabled():
		if holdingDuration > 0:
			holdingDuration = 0
		return
	current_cooldown = maxf(0, current_cooldown-delta)
	if Input.is_action_pressed("confirm"):
		if !shooting_disabled():
			holdingDuration += delta
			if holdingDuration >= big_shot_holding_duration:
				animateBigShottedness(delta)
	else:
		if holdingDuration > 0 && current_cooldown <= 0:
			if !shooting_disabled():
				shoot(holdingDuration>big_shot_holding_duration)
				holdingDuration = 0
				current_cooldown = shooting_cooldown
			soul.heart.modulate = soul.get_base_color()

func turn_end() -> void:
	holdingDuration = 0
	soul.heart.modulate = soul.get_base_color()
	clear_bullets()

func end() -> void:
	clear_bullets()

func clear_bullets() -> void:
	for bullet in bullets.filter(func(bul): return bul != null):
		bullet.queue_free()
	bullets.clear()

func animateBigShottedness(_delta : float) -> void:
	var amount := absf(sin(Time.get_ticks_msec()))
	soul.heart.modulate = soul.get_base_color().lerp(Color.WHITE_SMOKE, amount)

func shoot(is_big_shot : bool = false) -> void:
	var newPellet : JusticePellet = JUSTICE_PELLET.instantiate()
	newPellet.velocity = Vector2(200, 0).rotated(deg_to_rad(degrees + 90))
	newPellet.z_index = soul.z_index-1
	newPellet.is_big_shot = is_big_shot
	newPellet.global_position = soul.global_position + Vector2(8, 0).rotated(deg_to_rad(degrees + 90)) * soul.scale.x
	newPellet.battle = soul.battle
	bullets.append(newPellet)
	soul.get_parent().add_child(newPellet)

func set_direction(dir : Direction) -> void:
	degrees = Soul.heart_rotation(dir)
	face_direction = dir
	soul.visually_rotate(dir)
	soul.grazer.rotation_degrees = Soul.heart_rotation(dir)

func shooting_disabled() -> bool:
	return !soul.active || !shooting_enabled
