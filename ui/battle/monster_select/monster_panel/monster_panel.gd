extends SelectPanel
class_name MonsterPanel

var monster_id := 0

func set_current_hp(p_current_hp: int) -> void:
	$HPBar.value = p_current_hp
	$HPText.text = str(roundi(100.0 * p_current_hp / $HPBar.max_value)) + "%"

func set_max_hp(p_max_hp: int) -> void:
	$HPBar.max_value = p_max_hp
	$HPText.text = str(roundi(100.0 * $HPBar.value / p_max_hp)) + "%"

func set_mercy_percent(p_mercy_percent: float) -> void:
	$MercyBar.value = p_mercy_percent
	$MercyText.text = str(roundi(p_mercy_percent * 100.0)) + "%"
	$MercyText.modulate = Color.WHITE if p_mercy_percent < 1.0 else Global.YELLOW

func set_from_monster(p_monster: Monster) -> void:
	set_title(p_monster.title)
	
	set_max_hp(p_monster.get_max_hp())
	set_current_hp(p_monster.current_hp)
	monster_id = Global.monsters.find(p_monster)
	p_monster.health_changed.connect(set_current_hp)
	p_monster.mercy_changed.connect(set_mercy_percent)
