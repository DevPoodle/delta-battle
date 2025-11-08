extends Node2D

const TP_DECREASE_COLOR := Color("ff0f15")
const TP_INCREASE_COLOR := Color("ff0f15")

var desired_value := 0.0
var current_value := 0.0
var foam := 0.0

func _ready() -> void:
	Global.tp_changed.connect(set_tp)

func _process(_p_delta: float) -> void:
	$Fill.material.set_shader_parameter("fill", current_value / 250.0)
	$Fill.material.set_shader_parameter("foam_amount", foam)
	if is_equal_approx(current_value, 250.0):
		$Number.visible = false
		$TPMax.visible = true
	else:
		$Number.visible = true
		$TPMax.visible = false
		$Number.text = str(floori(current_value / 2.5))

func set_tp() -> void:
	desired_value = Global.tp
	animate_bar(desired_value < current_value)

func animate_bar(p_is_decreasing : bool) -> void:
	var foam_amount := absf(absf(current_value) - absf(desired_value)) / 3.0
	var time_multiplier := 1.0
	
	var tween := create_tween()
	if p_is_decreasing:
		$Fill.material.set_shader_parameter("change_color", TP_DECREASE_COLOR)
		tween.tween_property(self, "foam", foam_amount, 0.1 * time_multiplier)
		tween.tween_interval(0.01)
		tween.set_parallel(true)
		tween.tween_property(self, "current_value", desired_value, 0.05 * time_multiplier)
		tween.tween_property(self, "foam", 0, 0.05 * time_multiplier)
	else:
		$Fill.material.set_shader_parameter("change_color", TP_INCREASE_COLOR)
		tween.set_parallel(true)
		tween.tween_property(self, "current_value", desired_value, 0.1 * time_multiplier)
		tween.tween_property(self, "foam", foam_amount, 0.1 * time_multiplier)
		tween.set_parallel(false)
		tween.tween_property(self, "foam", 0, 0.3 * time_multiplier)
