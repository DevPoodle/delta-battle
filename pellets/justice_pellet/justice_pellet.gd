@tool
extends GenericPellet
class_name JusticePellet

@export var is_big_shot : bool = false

var health : int = 1

func _on_body_entered(body: Node2D) -> void:
	if body is Pellet && body.anti_justice:
		body.justice_shotted.emit((int(rotation_degrees) + 180) % 360)
		if !is_big_shot:
			queue_free()
