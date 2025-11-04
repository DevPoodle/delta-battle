extends Pellet

var velocity := 48.0
var moving := false

func _ready() -> void:
	if !visible:
		return
	
	await get_tree().create_timer(0.08).timeout
	$Sprite.frame = 1
	await get_tree().create_timer(0.08).timeout
	$Sprite.frame = 2
	moving = true

func _physics_process(delta: float) -> void:
	if !moving or !visible:
		return
	velocity += delta * 160.0
	position.y += velocity * delta
	if position.y >= 62.0:
		queue_free()
