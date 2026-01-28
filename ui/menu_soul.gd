extends Sprite2D

func _ready() -> void:
	change_state()
	Global.soulState.changed.connect(change_state)

func change_state() -> void:
	modulate = Global.soulState.type.color
	rotation_degrees = Soul.heart_rotation(Global.soulState.direction)
