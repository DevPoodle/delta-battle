extends Node2D

var direction := 1.0
var bouncing := false
var first_bounce := false
var rising := false
var time_til_bounce := 0.0
var velocity := 0.0

func _ready() -> void:
	$Pellet.position.y = -51.0
	time_til_bounce = randf_range(1.0, 3.0)

func _physics_process(delta: float) -> void:
	if bouncing:
		$Pellet.position.y += velocity * delta
		velocity += 720.0 * delta
		if $Pellet.position.y > 51.0:
			if first_bounce:
				$Pellet.position.y = 51.0
				velocity = -340.0
				first_bounce = false
			else:
				$Pellet.position.y = 51.0
				velocity = 0.0
				bouncing = false
				rising = true
		return
	if rising:
		var tween := get_tree().create_tween()
		tween.tween_property($Pellet, "position:y", -51.0, 0.7)
		await tween.finished
		rising = false
		time_til_bounce = randf_range(1.0, 3.0)
		return
	time_til_bounce -= delta
	$Pellet.position.x += direction * delta * 160.0
	if absf($Pellet.position.x) > 51.0:
		direction *= -1.0
		$Pellet.position.x = signf($Pellet.position.x) * 51.0
	if time_til_bounce <= 0.0:
		time_til_bounce = 0.0
		bouncing = true
		first_bounce = true
		velocity = -220.0
