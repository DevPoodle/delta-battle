@tool
extends GenericPellet
class_name JusticePellet

@onready var collision_shape_2d: CollisionPolygon2D = $Hitbox
@onready var sprite: Sprite2D = $Sprite
@onready var bigshot_hitbox: CollisionPolygon2D = $BigshotHitbox

const BIG_SHOT_TEXTURE := preload("res://pellets/justice_pellet/res/big_shot.png")

@export var battle : Battle
@export var is_big_shot : bool = false

var health : int = 1

func _ready() -> void:
	if is_big_shot:
		$Sprite.texture = BIG_SHOT_TEXTURE
		bigshot_hitbox.disabled = false
		collision_shape_2d.disabled = true

func _on_body_entered(body: Node2D) -> void:
	if body is Pellet && body.anti_justice:
		body.justice_shotted.emit((int(rotation_degrees) + 180) % 360)
		battle.tp += 2.5
		if !is_big_shot:
			queue_free()
