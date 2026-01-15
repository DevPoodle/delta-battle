extends Area2D

@export var soul : Soul

var graze_timer := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_tp_range_area_entered)
	area_exited.connect(_on_tp_range_area_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if graze_timer > 0.0:
		graze_timer -= delta
		$TPIndicator.modulate.a = maxf(0.0, 30.0 * graze_timer / 6.0 - 0.2)
	for pellet: Pellet in soul.grazed_pellets:
		graze(pellet, delta)

func graze(p_pellet: Pellet, p_delta: float) -> void:
	if soul.invulnerable:
		return
	if p_pellet.grazed:
		Global.tp += 30.0 * p_delta * p_pellet.graze_points * Global.tp_coefficient / 20.0
		if get_parent().get_parent().turn_timer >= 1.0 / 3.0:
			get_parent().get_parent().turn_timer -= 30.0 * p_delta * p_pellet.time_points / 20.0
		if graze_timer >= 0.0 and graze_timer < 4.0 / 30.0:
			graze_timer = 3.0 / 30.0
		elif graze_timer < 0.0:
			graze_timer = 2.0 / 30.0
	else:
		p_pellet.grazed = true
		Global.tp += p_pellet.graze_points
		if get_parent().get_parent().turn_timer >= 1.0 / 3.0:
			get_parent().get_parent().turn_timer -= p_pellet.time_points
		Sounds.play("snd_graze", 0.7)
		graze_timer = 1.0 / 3.0

func _on_tp_range_area_entered(p_area: Area2D) -> void:
	if p_area is Pellet:
		soul.grazed_pellets.append(p_area)
		graze(p_area, 1.0 / Engine.max_fps)

func _on_tp_range_area_exited(p_area: Area2D) -> void:
	if p_area is Pellet && soul.grazed_pellets.has(p_area):
		soul.grazed_pellets.erase(p_area)
