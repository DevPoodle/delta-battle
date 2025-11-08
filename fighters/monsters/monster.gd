extends AbstractFighter
class_name Monster

enum Animations {
	HURT, SPARE, FAINT
}

@export_multiline var description := ""
@export var acts: Array[Act] = []

@export var xp_bled := 10
@export var money_dropped := 5

@export var idle_lines: PackedStringArray
@export_multiline var opening_line_singular := "  * An enemy approaches."
@export_multiline var opening_line_plural := "  * Multiple enemies approach."

@export_node_path("Sprite2D") var main_sprite: NodePath
var sprite: Sprite2D
var mat: ShaderMaterial
var hurting := false
var dying := false
var mercy_percent := 0.0
var shake := 0.0

var attacks: Array[Node2D] = []

signal mercy_changed(p_new_mercy: float)
signal exit_finished
signal attack_finished

func _ready() -> void:
	if !main_sprite:
		return
	sprite = get_node(main_sprite)
	mat = ShaderMaterial.new()
	mat.shader = preload("res://fighters/monsters/generic_monster.gdshader")
	sprite.material = mat

func _process(p_delta: float) -> void:
	if shake > 0.0:
		shake = lerpf(shake, 0.0, 1.0 - pow(0.1, p_delta))
		sprite.position = Vector2(randf_range(-shake, shake), randf_range(-shake, shake))
		if shake <= 0.1:
			shake = 0.0
			sprite.position = Vector2.ZERO

func shake_sprite(amount: float) -> void:
	shake = amount

func do_animation(_p_animation: Animations) -> Signal:
	return get_tree().create_timer(0.1).timeout

func get_opening_line() -> String:
	for monster: Monster in Global.monsters:
		if monster == null or monster == self:
			continue
		return opening_line_plural
	return opening_line_singular

func get_idle_line() -> String:
	if idle_lines.is_empty():
		return "  * Keep fighting!"
	return idle_lines[randi_range(0, idle_lines.size() - 1)]

func set_selected(p_selected: bool) -> void:
	if !mat:
		return
	mat.set_shader_parameter("flash", float(p_selected))

func damage_or_die_animation() -> void:
	if !dying:
		hurting = true
		await do_animation(Animations.HURT)
		hurting = false
	else:
		await do_animation(Animations.HURT)
		shake = 0.0
		await do_animation(Animations.FAINT)
		exit_finished.emit()
		queue_free()

func take_damage(p_character: Character, p_damage: int) -> void:
	current_hp -= (p_damage - defense * 3)
	health_changed.emit(current_hp)
	Global.tp += 5 * Global.tp_coefficient
	create_text(str(p_damage) if p_damage > 0 else "MISS", p_character.icon_color)
	if current_hp < 0:
		dying = true
		Global.delete_monster(self, Global.DefeatContext.FLEE)

func increase_mercy(p_amount: float) -> void:
	p_amount = minf(p_amount, 1.0 - mercy_percent)
	mercy_percent = minf(1.0, mercy_percent + p_amount)
	create_text("+" + str(int(100.0 * p_amount)) + "%", Global.YELLOW)
	mercy_changed.emit(mercy_percent)

func spare() -> void:
	shake = 0.0
	await do_animation(Animations.SPARE)
	Global.delete_monster(self, Global.DefeatContext.SPARED)
	exit_finished.emit()
	queue_free()

func start_attack() -> float:
	return 0.1

func end_attack() -> void:
	for attack: Node2D in attacks:
		if attack != null:
			attack.queue_free()
	attacks.clear()

func instantiate_attack(scene: PackedScene) -> void:
	var attack := scene.instantiate()
	get_parent().add_child(attack)
	attack.position = Global.CENTER
	attacks.append(attack)

func get_acts() -> Array[Act]:
	return acts
