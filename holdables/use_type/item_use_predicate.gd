extends Resource
class_name ItemUsePredicate

var item : Item
@export var remove_after_use : bool = false

@warning_ignore("unused_parameter")
func use_item(user : Character, used_on : Character) -> Signal:
	display_use_text(user)
	await Global.text_finished
	await user.get_tree().create_timer(0.01).timeout
	Global.display_text.emit("  * But nothing happened...", true)
	return Global.text_finished

func display_use_text(user : Character) -> void:
	Global.display_text.emit("  * " + user.title + " used the " + item.name + ".", true)
