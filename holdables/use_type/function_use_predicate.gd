extends ItemUsePredicate
class_name FunctionUsePredicate

##Function must return a signal that the battle will use to advance the turn.
@export var callable : Callable = func(user : Character, used_on : Character): return

func use_item(user : Character, used_on : Character) -> Signal:
	display_use_text(user)
	return callable.call(user, used_on)
