extends CharacterBody2D
class_name Soul

const SPEED := 4.0 * 30.0 # 4 pixels per frame
const SLOW_MULTIPLIER := 0.5
var active := false:
	set(p_active):
		active = p_active
		grazed_pellets.clear()
var grazed_pellets: Array[Pellet] = []
var graze_timer := 0.0
var invulnerable := false


func _physics_process(delta: float) -> void:
	if graze_timer > 0.0:
		graze_timer -= delta
		$TPIndicator.modulate.a = maxf(0.0, 30.0 * graze_timer / 6.0 - 0.2)
	if !active:
		return
	
	var input := Vector2(
		int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")),
		int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	).normalized()
	
	velocity = Vector2.ZERO
	if input != Vector2.ZERO:
		velocity = SPEED * input
		if Input.is_action_pressed("cancel"):
			velocity *= 0.5
	move_and_slide()
	for pellet: Pellet in grazed_pellets:
		graze(pellet, delta)

func hurt(p_damage: int) -> void:
	if(invulnerable):
		return
	get_parent().hurt(5 * p_damage)
	invulnerable = true
	$AnimationPlayer.play("invulnerable")
		
	

func _on_tp_range_area_entered(p_area: Area2D) -> void:
	grazed_pellets.append(p_area)
	graze(p_area, 1.0 / Engine.max_fps)

func _on_tp_range_area_exited(p_area: Area2D) -> void:
	grazed_pellets.erase(p_area)

func graze(p_pellet: Pellet, p_delta: float) -> void:
	if(invulnerable):
		return
	if p_pellet.grazed:
		Global.tp += 30.0 * p_delta * p_pellet.graze_points / 20.0
		if get_parent().turn_timer >= 1.0 / 3.0:
			get_parent().turn_timer -= 30.0 * p_delta * p_pellet.time_points / 20.0
		if graze_timer >= 0.0 and graze_timer < 4.0 / 30.0:
			graze_timer = 3.0 / 30.0
		elif graze_timer < 0.0:
			graze_timer = 2.0 / 30.0
	else:
		p_pellet.grazed = true
		Global.tp += p_pellet.graze_points
		if get_parent().turn_timer >= 1.0 / 3.0:
			get_parent().turn_timer -= p_pellet.time_points
		Sounds.play("snd_graze", 0.7)
		graze_timer = 1.0 / 3.0


func _on_animation_player_animation_finished(anim_invulnerable):
	if anim_invulnerable == "invulnerable":
		invulnerable = false
	pass # Replace with function body.
