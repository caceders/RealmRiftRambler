class_name FreezeSpellComponent extends SpellComponent

@export var target: AffectEntity = AffectEntity.TARGET
@export var time: float = 0

func activate(spell_caster: SpellCaster):
	var entity: Node2D = null
	match target:
		AffectEntity.CASTER:
			if spell_caster.parent != null:
				entity =  spell_caster.parent
				
		AffectEntity.TARGET:
			if spell_caster.target != null:
				entity = spell_caster.target
				
		_:
			pass
	if entity == null:
		return

	var top_down_entity_2D = null
	if entity.has_node("TopDownEntity2D"):
		top_down_entity_2D =entity.get_node("TopDownEntity2D") as TopDownEntity2D
		top_down_entity_2D.reacts_to_direction = false

	var animation_player_controller = null 
	if entity.has_node("AnimationPlayerController"):
		animation_player_controller = entity.get_node("AnimationPlayerController") as AnimationPlayerController
		animation_player_controller.disable()

	if time == 0:
		return
	
	# Add freeze timer if it does not exist, else reset it
	var freeze_timer = null
	if entity.has_node("FreezeTimer"):
		freeze_timer = entity.get_node("FreezeTimer") as Timer
		freeze_timer.stop()
		freeze_timer.start(time)
		return
	else:
		freeze_timer = Timer.new() as Timer
		freeze_timer.name = "FreezeTimer"
		entity.add_child(freeze_timer)
		freeze_timer.one_shot = true
		freeze_timer.start(time)
		
	await freeze_timer.timeout
	freeze_timer.queue_free()
	if top_down_entity_2D != null:
		top_down_entity_2D.reacts_to_direction = true
	if animation_player_controller != null:
		animation_player_controller.enable()
