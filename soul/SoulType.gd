extends Resource
class_name SoulType

@export var color : Color
@export var is_monster_soul : bool = false
@export var behaviors : Array[Script]

func _init(heart_color : Color) -> void:
	color = heart_color

func addBehaviorAbsolute(node_path : String) -> SoulType:
	behaviors.append(load(node_path))
	return self

func addBehavior(node_name : String) -> SoulType:
	addBehaviorAbsolute("res://soul/behaviors/" + node_name + ".gd")
	return self

func set_monster(value : bool = true) -> SoulType:
	is_monster_soul = value
	return self

func get_secondary_color() -> Color:
	var final_color : Color = color
	final_color.r *= 0.5
	final_color.g *= 0.5
	final_color.b *= 0.5
	return final_color

static var RED := SoulType.new(Color("FF0000")).addBehavior("movement/soul_move")
static var CYAN := SoulType.new(Color("42FCFF"))
static var ORANGE := SoulType.new(Color("FCA600"))
static var BLUE := SoulType.new(Color("003CFF")).addBehavior("movement/blue_soul_move")
static var PURPLE := SoulType.new(Color("D535D9"))
static var GREEN := SoulType.new(Color("00C000")).addBehavior("shielding_behavior")
static var YELLOW := SoulType.new(Color("FFFF00"))
