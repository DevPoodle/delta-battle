@tool
extends Spell
class_name BasicHeal

@export var heal_amount := 50:
	set(p_heal_amount):
		heal_amount = maxi(0, p_heal_amount)
@export var animation_code := Character.Animations.ATTACK

func _init() -> void:
	if Engine.is_editor_hint():
		title = "Heal"
		text = "  * %s healed %s."
		description = "Heal ally."
		target = 0

func do_spell(p_from: Character, p_to: Node2D) -> void:
	if !(p_to is Character):
		p_from.spell_finished.emit()
		return
	
	var to := p_to as Character
	to.heal(heal_amount)
	p_from.do_animation(animation_code)
	Global.display_text.emit(text % [p_from.title, to.title], true)
	await Global.text_finished
	p_from.spell_finished.emit()
