extends Character

func do_animation(p_animation: Animations) -> Signal:
	match p_animation:
		Animations.IDLE:
			$AnimationPlayer.play("idle")
		Animations.PREP_ATTACK:
			$AnimationPlayer.play("prep_attack")
		Animations.PREP_ACT:
			$AnimationPlayer.play("prep_act")
		Animations.PREP_ITEM:
			$AnimationPlayer.play("prep_act")
		Animations.PREP_SPARE:
			$AnimationPlayer.play("prep_act")
		Animations.ATTACK:
			$AnimationPlayer.play("attack")
		Animations.ACT:
			$AnimationPlayer.play("act")
		Animations.USE_ITEM:
			$AnimationPlayer.play("act")
		Animations.DEFEND:
			$AnimationPlayer.play("defend")
		Animations.SPARE:
			$AnimationPlayer.play("act")
		Animations.FAINT:
			$AnimationPlayer.play("faint")
		Animations.REVIVE:
			$AnimationPlayer.play("RESET")
			$AnimationPlayer.play("idle")
	return $AnimationPlayer.animation_finished
