extends Act
class_name CheckAct

func do_act(p_from: Character, p_to: Monster):
	await p_from.do_animation(Character.Animations.ACT)
	Global.display_text.emit(p_to.description, true)
	await Global.text_finished
	p_from.do_animation(Character.Animations.IDLE)
	p_from.act_finished.emit()
