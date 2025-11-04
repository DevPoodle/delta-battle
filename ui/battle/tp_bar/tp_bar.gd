extends Node2D

const TP_DECREASE_COLOR : Color = Color("FF0F15")
const TP_INCREASE_COLOR : Color = Color("FF0F15")

var desiredValue : float = 0
var currentValue : float = 0
var foam : float = 0

func _ready() -> void:
	Global.tp_changed.connect(set_tp)

func _process(_delta: float) -> void:
	$Fill.material.set_shader_parameter("fill", currentValue / 250.0)
	$Fill.material.set_shader_parameter("foam_amount", foam)
	if is_equal_approx(currentValue, 250.0):
		$Number.visible = false
		$TPMax.visible = true
	else:
		$Number.visible = true
		$TPMax.visible = false
		$Number.text = str(floori(currentValue / 2.5))

func set_tp() -> void:
	desiredValue = Global.tp
	animateBar(desiredValue < currentValue)

func animateBar(isDecreasing : bool) -> void:
	
	var foamAmount : float = abs(abs(currentValue)-abs(desiredValue))/3
	var timeMultiplier : float = 1
	
	var tween = create_tween()
	if isDecreasing:
		$Fill.material.set_shader_parameter("change_color", TP_DECREASE_COLOR)
		tween.tween_property(self, "foam", foamAmount, 0.1 * timeMultiplier)
		tween.tween_interval(0.01)
		tween.set_parallel(true)
		tween.tween_property(self, "currentValue", desiredValue, 0.05 * timeMultiplier)
		tween.tween_property(self, "foam", 0, 0.05 * timeMultiplier)
	else:
		$Fill.material.set_shader_parameter("change_color", TP_INCREASE_COLOR)
		tween.set_parallel(true)
		tween.tween_property(self, "currentValue", desiredValue, 0.1 * timeMultiplier)
		tween.tween_property(self, "foam", foamAmount, 0.1 * timeMultiplier)
		tween.set_parallel(false)
		tween.tween_property(self, "foam", 0, 0.3 * timeMultiplier)
