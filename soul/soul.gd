extends CharacterBody2D
class_name Soul

@onready var collision: CollisionPolygon2D = $Collision
@onready var grazer: Area2D = $Grazer
@export var heart: Sprite2D
@export var behaviors : Array[SoulBehavior]

var baseColor : Color = Color.WHITE
var secondaryColor : Color = Color.GRAY

var active := false:
	set(p_active):
		active = p_active
		grazed_pellets.clear()
var grazed_pellets: Array[Pellet] = []
var invulnerable := false

func _ready() -> void:
	assign_heart_properties(SoulType.YELLOW)
	for i in behaviors:
		i.soul = self
		i.start()

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
	tween.tween_property(heart, "modulate", secondaryColor, 0.0)
	tween.tween_interval(0.1)
	tween.tween_property(heart, "modulate", baseColor, 0.0)
	tween.tween_interval(0.2)
	await tween.finished
	invulnerable = false

func change_color(soulType : SoulType) -> void:
	baseColor = soulType.color
	secondaryColor = soulType.get_secondary_color()
	heart.modulate = soulType.color
	Global.setHeartColor(soulType.color)

func assign_heart_properties(soulType : SoulType) -> void:
	change_color(soulType)
	for i in behaviors:
		i.end()
		i.queue_free()
	behaviors.clear()
	for i in soulType.behaviors:
		var newBehavior := Node.new()
		newBehavior.set_script(i)
		add_child(newBehavior)
		behaviors.append(newBehavior)
