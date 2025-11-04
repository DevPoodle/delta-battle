extends Node2D

var time_til_droplet := 0.1

func _physics_process(delta: float) -> void:
	time_til_droplet -= delta
	if time_til_droplet < 0.0:
		time_til_droplet = randf_range(0.15, 0.3)
		var new_droplet: Pellet = $BaseDroplet.duplicate()
		new_droplet.visible = true
		new_droplet.position = Vector2(randf_range(-67.0, 67.0), -62.0)
		add_child(new_droplet)
