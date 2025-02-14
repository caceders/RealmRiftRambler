class_name PauseSpellComponent extends SpellComponent

@export var pause_time_seconds: float = .5

func activate(spell_caster: SpellCaster):
	var timer = Timer.new()
	timer.one_shot = true
	spell_caster.add_child(timer)
	timer.start(pause_time_seconds)
	await timer.timeout
	timer.queue_free()