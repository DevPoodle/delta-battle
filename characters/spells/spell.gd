extends Resource
class_name Spell

@export var title := "Nothing"
@export_multiline var text := "  * Nothing happened."
@export var description := "Does nothing."
@export_range(0, 100, 1) var tp_percent_cost := 10
@export_enum("To Character", "To Enemy") var target := 0

func do_spell(p_from: Character, _p_to: Node2D) -> void:
	Global.display_text.emit(text, true)
	await Global.text_finished
	p_from.spell_finished.emit()
