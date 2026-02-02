extends CharacterBody2D
class_name Soul

@onready var collision: CollisionPolygon2D = $Collision
@onready var grazer: Area2D = $Grazer
@export var heart: Sprite2D
@export var behaviors: Array[SoulBehavior]

var current_soul_type: SoulType

var active := false:
	set(p_active):
		active = p_active
		grazed_pellets.clear()
		for beh in behaviors:
			if p_active:
				beh.turn_start()
			else:
				beh.turn_end()
var grazed_pellets: Array[Pellet] = []
var invulnerable := false

func _ready() -> void:
	assign_heart_properties(SoulType.RED)

func _process(delta: float) -> void:
	for i in behaviors:
		i.tick(delta)

func _physics_process(delta: float) -> void:
	for i in behaviors:
		i.physics_tick(delta)

func hurt(p_damage: int) -> void:
	if invulnerable:
		return
	get_parent().hurt(5 * p_damage)
	invulnerable_state()

func invulnerable_state()-> void:
	invulnerable = true
	var tween = get_tree().create_tween()
	tween.set_loops(5)
	tween.tween_property(heart, "modulate", current_soul_type.get_secondary_color(), 0.0)
	tween.tween_interval(0.1)
	tween.tween_property(heart, "modulate", current_soul_type.color, 0.0)
	tween.tween_interval(0.2)
	await tween.finished
	invulnerable = false

func change_color(soulType : SoulType) -> void:
	current_soul_type = soulType
	heart.modulate = current_soul_type.color
	Global.setHeartColor(current_soul_type.color)

func get_base_color() -> Color:
	return current_soul_type.color

func get_secondary_color() -> Color:
	return current_soul_type.get_secondary_color()

func assign_heart_properties(soulType : SoulType) -> void:
	change_color(soulType)
	for i in behaviors:
		i.end()
		i.queue_free()
	behaviors.clear()
	for i in soulType.behaviors:
		var newBehavior := Node.new()
		newBehavior.set_script(i)
		newBehavior.soul = self
		add_child(newBehavior)
		behaviors.append(newBehavior)
		newBehavior.start()

func visually_rotate(deg : float) -> void:
	collision.rotation_degrees = deg
	heart.rotation_degrees = deg
