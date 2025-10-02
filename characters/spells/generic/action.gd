@tool
extends Spell
class_name CharAction

@export var animation_code := Character.Animations.ACT

## [ Enemy_Name, Flavor_Text ]
@export var flavor_texts: Dictionary[String, String]
## The amoun of mercy the enemy gains
@export var spare_percent: float

func _init() -> void:
	if Engine.is_editor_hint():
		title = "char-Action"
		text = "  * %s healed %s."
		description = "Standard Act."
		target = 0

func do_spell(p_from: Character, p_to: Node2D) -> void:
	if !(p_to is Monster):
		p_from.spell_finished.emit()
		return
	
	var to := p_to as Monster
	p_from.do_animation(animation_code)
	to.increase_mercy(spare_percent)
	Global.display_text.emit("* "+str(flavor_texts[to.title]), true)
	await Global.text_finished
	await Global.wait_time(0.01)
	p_from.spell_finished.emit()
