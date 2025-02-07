class_name SpellAnimationOverlay extends SpellComponent

@export var animation_packed_scene: PackedScene

@export var target: AffectEntity = AffectEntity.TARGET

func activate(spell_caster: SpellCaster):
	var animation_scene = animation_packed_scene.instantiate()
	var animation_player = animation_scene.get_node("AnimationPlayer") as AnimationPlayer
	var sprite: Sprite2D
	match target:
		AffectEntity.CASTER:
			if spell_caster.parent != null:
				spell_caster.parent.add_child(animation_scene)
				if spell_caster.parent.has_node("Sprite2D"):
					sprite = spell_caster.parent.get_node("Sprite2D") as Sprite2D
		AffectEntity.TARGET:
			if spell_caster.target != null:
				spell_caster.target.add_child(animation_scene)
				if spell_caster.target.has_node("Sprite2D"):
					sprite = spell_caster.target.get_node("Sprite2D") as Sprite2D
	
	if sprite != null:
		animation_scene.position.y = - sprite.texture.get_size().y/2
	var animation = animation_player.get_animation_list()
	animation_player.play(animation[0])
	await animation_player.animation_finished
	animation_scene.queue_free()
