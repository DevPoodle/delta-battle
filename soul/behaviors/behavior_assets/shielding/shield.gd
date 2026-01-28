extends Area2D
class_name Shield

signal collided_with_pellet

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func repel_pellet(_pellet : Pellet) -> void:
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("collide")
	collided_with_pellet.emit()

func _on_area_entered(area: Area2D) -> void:
	if area is Pellet && area.shield_repelled:
		repel_pellet(area)
		area.queue_free()
