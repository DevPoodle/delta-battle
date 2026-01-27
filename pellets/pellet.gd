extends Area2D
class_name Pellet

signal justice_shotted(shot_direction : float)

@export var damage := 1
## The amount of TP gained by grazing
@export var graze_points := 5
## How much the turn timer is reduced when grazing (in seconds)
@export var time_points := 5.0 / 30.0
##Whether the pellet is repelled by a shield.
@export var shield_repelled : bool = false
##Whether the pellet is destroyed by yellow soul bullets.
@export var anti_justice : bool = false

var grazed := false

func _on_body_entered(body: Node2D) -> void:
	if body is Soul:
		body.hurt(damage)
