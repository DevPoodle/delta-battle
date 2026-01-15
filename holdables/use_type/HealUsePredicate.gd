extends ItemUsePredicate
class_name HealUsePredicate

@export var amount : int

func use_item(user : Character, used_on : Character) -> Signal:
	used_on.heal(amount)
	display_use_text(user)
	return Global.text_finished
