extends Node
class_name SoulBehavior

## The instace of the soul using this behavior. It is set automatically when the behavior is applied.
@export var soul : Soul

## Runs when the behavior is first applied to the soul.
func start() -> void:
	pass

## Runs every frame using the _process function.
@warning_ignore("unused_parameter")
func tick(delta : float) -> void:
	pass

## Runs every frame using the _physics_process function.
@warning_ignore("unused_parameter")
func physics_tick(delta : float) -> void:
	pass

## Runs when the behavior is removed from the soul.
func end() -> void:
	pass

## Runs right after the soul is moved into the soul cage.
func turn_start() -> void:
	pass

## Runs right as the soul is being pulled out of the soul cage.
func turn_end() -> void:
	pass
