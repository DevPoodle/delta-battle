extends Control
class_name SelectPanel

@export_node_path("Sprite2D") var heart_path
@export_node_path("Label") var title_path

var heart: Sprite2D
var title: Label

func _ready() -> void:
	heart = get_node_or_null(heart_path)
	title = get_node_or_null(title_path)

func set_select(p_selected: bool) -> void:
	if !heart:
		if !heart_path:
			return
		heart = get_node_or_null(heart_path)
	heart.modulate = Global.heartColor
	heart.visible = p_selected

func set_title(p_title: String) -> void:
	if !title:
		if !title_path:
			return
		title = get_node_or_null(title_path)
	title.text = p_title
