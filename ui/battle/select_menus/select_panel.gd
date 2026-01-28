extends Control
class_name SelectPanel

const MENU_SOUL_SCRIPT := preload("res://ui/menu_soul.gd")

@export var battle : Battle
@export_node_path("Sprite2D") var heart_path
@export_node_path("Label") var title_path

var heart: Sprite2D
var title: Label

func _ready() -> void:
	heart = get_node_or_null(heart_path)
	if heart != null:
		heart.set_script(MENU_SOUL_SCRIPT)
		heart.change_state()
	title = get_node_or_null(title_path)

func set_select(p_selected: bool) -> void:
	if !heart:
		if !heart_path:
			return
		heart = get_node_or_null(heart_path)
	heart.visible = p_selected

func set_title(p_title: String) -> void:
	if !title:
		if !title_path:
			return
		title = get_node_or_null(title_path)
	title.text = p_title
