extends Resource
class_name Direction

static var DIRECTION_FROM_DEGREES : Dictionary[int, Direction] ={}
static var DIRECTION_FROM_VECTOR : Dictionary[Vector2i, Direction] ={}

@export var positive_degrees : int
@export var negative_degrees : int
@export var vector : Vector2i

func _init(pos : int, neg : int, vec : Vector2i) -> void:
	positive_degrees = pos
	negative_degrees = neg
	vector = vec
	DIRECTION_FROM_DEGREES.set(positive_degrees, self)
	DIRECTION_FROM_DEGREES.set(negative_degrees, self)
	DIRECTION_FROM_VECTOR.set(vec, self)

static var NORTH = Direction.new(270, -90, Vector2i.UP)
static var NORTH_EAST = Direction.new(315, -45, Vector2i(1, -1))
static var EAST = Direction.new(0, -360, Vector2i.RIGHT)
static var SOUTH_EAST = Direction.new(45, -315, Vector2i(1, 1))
static var SOUTH = Direction.new(90, 270, Vector2i.DOWN)
static var SOUTH_WEST = Direction.new(135, -225, Vector2i(-1, 1))
static var WEST = Direction.new(180, -180, Vector2i.LEFT)
static var NORTH_WEST = Direction.new(225, -135, Vector2i(-1, -1))

func opposite() -> Direction:
	return get_direction_transmuted(180)

func left(diagonal : bool = false) -> Direction:
	var turn_amount : int = 90
	if diagonal:
		turn_amount = 45
	return get_direction_transmuted(turn_amount)

func right(diagonal : bool = false) -> Direction:
	var turn_amount : int = -90
	if diagonal:
		turn_amount = -45
	return get_direction_transmuted(turn_amount)

func get_direction_transmuted(p_degrees : int) -> Direction:
	return DIRECTION_FROM_DEGREES.get((positive_degrees + p_degrees) % 360, DIRECTION_FROM_DEGREES.get((negative_degrees + p_degrees) % 360))

static func from_degrees(p_degrees : int) -> Direction:
	return DIRECTION_FROM_DEGREES.get(p_degrees)

static func from_vector(p_vector : Vector2i) -> Direction:
	return DIRECTION_FROM_VECTOR.get(p_vector)
