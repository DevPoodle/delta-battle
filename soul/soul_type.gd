extends Resource
class_name SoulType

## Color of the soul.
@export var color : Color
## Wether the soul is a monster soul or not. Currently does nothing.
@export var is_monster_soul : bool = false
## Array of behaviors that the soul will use when in this mode.
@export var behaviors : Array[Script]

func _init(heart_color : Color) -> void:
	color = heart_color


## Adds the behavior using the absolute path of the script.
func addBehaviorAbsolute(node_path : String) -> SoulType:
	behaviors.append(load(node_path))
	return self

## Used to create instances of default behavior, shouldn't be used if the behavior you want is somewhere else.
func addBehavior(node_name : String) -> SoulType:
	addBehaviorAbsolute("res://soul/behaviors/" + node_name + ".gd")
	return self
##Set wether the soul is a monster soul.
func set_monster(value : bool = true) -> SoulType:
	is_monster_soul = value
	return self
##Returns the color the soul flashes when it is damaged.
func get_secondary_color() -> Color:
	var final_color : Color = color
	final_color.r *= 0.5
	final_color.g *= 0.5
	final_color.b *= 0.5
	return final_color

##Creates a soul type instance with the default movement.
static func basic_moving_soul(p_color : Color) -> SoulType:
	return SoulType.new(p_color).addBehavior("movement/soul_move")

static var RED := basic_moving_soul(Color("FF0000"))
static var CYAN := basic_moving_soul(Color("42FCFF"))
static var ORANGE := basic_moving_soul(Color("FCA600"))
static var BLUE := SoulType.new(Color("003CFF")).addBehavior("movement/blue_soul_move")
static var PURPLE := SoulType.new(Color("D535D9")).addBehavior("movement/string_move")
static var GREEN := SoulType.new(Color("00C000")).addBehavior("shielding_behavior")
static var YELLOW := basic_moving_soul(Color("FFFF00")).addBehavior("shoot_behavior")
