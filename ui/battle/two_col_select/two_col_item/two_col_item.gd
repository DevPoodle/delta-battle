extends SelectPanel
class_name TwoColItem

var description := ""
var tp := 0.0

func initialize(p_title: String, p_description := "", p_tp := 0.0) -> void:
	set_title(p_title)
	description = p_description
	tp = p_tp

func set_select(p_selected: bool) -> void:
	if !heart:
		return
	heart.visible = p_selected
	update_modulation()

func update_modulation() -> void:
	if tp > Global.current_battle.tp:
		modulate = Color("#808080")
	else:
		modulate = Color.WHITE
