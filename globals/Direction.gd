extends Resource
class_name Util

enum Direction {
	NORTH,
	NORTH_EAST,
	EAST,
	SOUTH_EAST,
	SOUTH,
	SOUTH_WEST,
	WEST,
	NORTH_WEST
}

static func getLeft(dir : Direction, diagonal : bool = false):
	match dir:
		Direction.NORTH:
			if diagonal:
				return Direction.NORTH_WEST
			return Direction.WEST
		Direction.SOUTH:
			if diagonal:
				return Direction.SOUTH_EAST
			return Direction.EAST
		Direction.EAST:
			if diagonal:
				return Direction.NORTH_EAST
			return Direction.NORTH
		Direction.WEST:
			if diagonal:
				return Direction.SOUTH_WEST
			return Direction.SOUTH
		Direction.NORTH_EAST:
			return Direction.NORTH
		Direction.SOUTH_EAST:
			return Direction.EAST
		Direction.NORTH_WEST:
			return Direction.WEST
		Direction.SOUTH_WEST:
			return Direction.SOUTH

static func getOpposite(dir):
	match dir:
		Direction.NORTH:
			return Direction.SOUTH
		Direction.SOUTH:
			return Direction.NORTH
		Direction.EAST:
			return Direction.WEST
		Direction.WEST:
			return Direction.EAST
		Direction.NORTH_EAST:
			return Direction.SOUTH_WEST
		Direction.SOUTH_EAST:
			return Direction.NORTH_WEST
		Direction.NORTH_WEST:
			return Direction.SOUTH_EAST
		Direction.SOUTH_WEST:
			return Direction.NORTH_EAST

static func getRight(dir : Direction, diagonal : bool = false):
	return getLeft(getOpposite(dir), diagonal)

const ROTATION_DEGREES_FROM_DIR : Dictionary[Direction, float] ={
	Direction.NORTH: 90,
	Direction.SOUTH: 270,
	Direction.EAST: 0,
	Direction.WEST: 180,
	Direction.NORTH_EAST: 45,
	Direction.NORTH_WEST: 135,
	Direction.SOUTH_EAST: 315,
	Direction.SOUTH_WEST: 225
}
