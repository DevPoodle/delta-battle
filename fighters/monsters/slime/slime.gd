extends Monster
class_name Slime

const SLIME_BOUNCE := preload("res://fighters/monsters/slime/attacks/slime_bounce/slime_bounce.tscn")
const SLIME_DRIP := preload("res://fighters/monsters/slime/attacks/slime_drip/slime_drip.tscn")

var velocity := 0.0
var squishing := false

func do_animation(p_animation: Animations) -> Signal:
	match p_animation:
		Animations.HURT:
			$AnimationPlayer.play("hurt")
			velocity = 0.0
			squishing = false
		Animations.SPARE:
			$AnimationPlayer.play("spare")
		Animations.FAINT:
			$AnimationPlayer.play("die")
	return $AnimationPlayer.animation_finished

func _physics_process(delta: float) -> void:
	if shake > 0.0 or squishing or hurting or dying:
		return
	if sprite.position.y > 0.0:
		velocity = remap(mercy_percent, 0.0, 1.0, 160.0, 240.0)
		sprite.frame = 1
		sprite.position.y = 0.0
		squishing = true
		await get_tree().create_timer(0.2).timeout
		squishing = false
		return
	sprite.position.y -= velocity * delta
	sprite.frame = 0 if absf(velocity) < 48.0 else 2
	velocity -= 196.0 * delta

func start_attack() -> float:
	var another_slime := false
	for monster: Monster in Global.monsters:
		if monster == self:
			continue
		if monster is Slime:
			another_slime = true
			break
	attacks.clear()
	var attack := randi_range(0, 1 if !another_slime else 4)
	match attack:
		0:
			instantiate_attack(SLIME_BOUNCE)
		1:
			instantiate_attack(SLIME_DRIP)
		_:
			instantiate_attack(SLIME_BOUNCE)
			instantiate_attack(SLIME_DRIP)
	return 8.0
