extends Node2D

signal fade_finished

func fade_out() -> void:
	fade(Color.BLACK)

func fade_in() -> void:
	fade(Color.WHITE)

func fade(color : Color) -> void:
	var tween := get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($CanvasModulate, "color", color, 0.8)
	tween.finished.connect(fade_finished.emit)
