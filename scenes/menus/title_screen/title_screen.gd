extends Node2D

var dark_candy := preload("res://holdables/items/dark_candy.tres")

func _ready() -> void:
	$Play.grab_focus()
	Sounds.set_music("castletown", 0.8)

func _on_play_focus_entered() -> void:
	$Heart.position = $Play.position + Vector2(-16.0, 48.0 / 2.0 + 2.0)
	Sounds.play("snd_menumove")

func _on_quit_focus_entered() -> void:
	$Heart.position = $Quit.position + Vector2(-16.0, 48.0 / 2.0 + 2.0)
	Sounds.play("snd_menumove")

func _on_play_pressed() -> void:
	Sounds.play("snd_select")
	Global.items = [
		dark_candy, dark_candy, dark_candy, dark_candy, dark_candy, dark_candy, dark_candy, dark_candy
	]
	Global.change_to_scene("res://scenes/menus/customize_battle/customize_battle.tscn", false)

func _on_quit_pressed() -> void:
	get_tree().quit()
