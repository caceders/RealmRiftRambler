class_name IncreaseSpeedSpellComponent extends SpellComponent

@export var target: AffectEntity = AffectEntity.CASTER
@export var time: float = 10
@export var speed_increase: float = 100

func activate(spell_caster: SpellCaster):
	var entity: Node2D = null
	match target:
		AffectEntity.CASTER:
			if spell_caster.parent != null:
				entity =  spell_caster.parent
				
		AffectEntity.TARGET:
			if spell_caster.target != null:
				entity = spell_caster.target
				
	if entity == null:
		return

	var top_down_entity_2D = null
	if entity.has_node("TopDownEntity2D"):
		top_down_entity_2D =entity.get_node("TopDownEntity2D") as TopDownEntity2D
		if top_down_entity_2D != null:
			top_down_entity_2D.speed += speed_increase

	# Add speed timer if it does not exist, else reset it
	var speed_timer = null
	if entity.has_node("FreezeTimer"):
		speed_timer = entity.get_node("FreezeTimer") as Timer
		speed_timer.stop()
		speed_timer.start(time)
		return
	else:
		speed_timer = Timer.new() as Timer
		speed_timer.name = "FreezeTimer"
		entity.add_child(speed_timer)
		speed_timer.one_shot = true
		speed_timer.start(time)

	await speed_timer.timeout
	speed_timer.queue_free()
	if top_down_entity_2D != null:
		top_down_entity_2D.speed -= speed_increase