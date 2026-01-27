extends SoulMove

@export var xClamp : float = 65


@export var line_count : int = 5
@export var line_spacing : float = 30

var lines : Array[ColorRect]

var currentIndex : int = 0
var moving_along_strings : bool = false

func start() -> void:
	super.start()
	set_axis(MoveAxis.X)

func physics_tick(delta : float) -> void:
	soul.position.x = clampf(soul.position.x, soul.get_parent().soul_cage.position.x - xClamp, soul.get_parent().soul_cage.position.x + xClamp)
	super.physics_tick(delta)

func _unhandled_input(event: InputEvent) -> void:
	if moving_along_strings || !soul.active:
		return
	
	var index_changed := false
	if event.is_action_pressed("down") && currentIndex < lines.size() - 1:
		currentIndex += 1
		index_changed = true
	elif event.is_action_pressed("up") && currentIndex > 0:
		currentIndex -= 1
		index_changed = true
	if index_changed:
		move_to_line(currentIndex)

func move_to_line(index : int) -> void:
	moving_along_strings = true
	var tween = create_tween()
	var newPos := Vector2(soul.global_position.x, lines[index].global_position.y)
	tween.tween_property(soul, "global_position", newPos, 0.1)
	tween.tween_callback(func(): moving_along_strings = false)

func turn_start() -> void:
	super.turn_start()
	var initial_rect_pos : Vector2 = soul.get_parent().soul_cage.global_position
	initial_rect_pos.y -= (line_spacing + 1) * (line_count/2)
	for i in range(line_count):
		var newRect : ColorRect = ColorRect.new()
		newRect.color = SoulType.PURPLE.color
		newRect.size = Vector2(xClamp*2, 1)
		newRect.global_position = initial_rect_pos - newRect.size/2
		newRect.z_index = soul.z_index
		lines.append(newRect)
		soul.get_parent().add_child(newRect)
		initial_rect_pos.y += line_spacing
	currentIndex = floori(lines.size()/2.0)
	move_to_line(currentIndex)

func turn_end() -> void:
	super.turn_end()
	for i in lines:
		i.queue_free()
	lines.clear()

func getInput() -> Vector2:
	if moving_along_strings:
		return Vector2.ZERO
	return super.getInput()
