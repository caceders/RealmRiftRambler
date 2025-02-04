class_name ApplyShaderSpellComponent extends SpellComponent

@export var color: Color
@export var target: AffectEntity = AffectEntity.TARGET

# if set to -1 time is infinite
@export var time: float = 0

var color_change: Color

func activate(spell_caster: SpellCaster):
	var sprite_2d: Sprite2D
	match target:
		AffectEntity.CASTER:
			if spell_caster.parent != null:
				sprite_2d = spell_caster.parent.get_node("Sprite2D") as Sprite2D
				
				
		AffectEntity.TARGET:
			if spell_caster.target != null:
				sprite_2d = spell_caster.target.get_node("Sprite2D") as Sprite2D

	sprite_2d.modulate = Color(sprite_2d.modulate.r + color.r, sprite_2d.modulate.g + color.g, sprite_2d.modulate.b + color.b)

	if time == 0:
		return

	# Add color change timer if it does not exist, else reset it
	var color_change_timer = Timer.new() as Timer
	color_change_timer.name = "ColorChangeTimer"
	sprite_2d.add_child(color_change_timer)
	color_change_timer.one_shot = true
	color_change_timer.start(time)

	await color_change_timer.timeout
	color_change_timer.queue_free()
	sprite_2d.modulate = Color(sprite_2d.modulate.r - color.r, sprite_2d.modulate.g - color.g, sprite_2d.modulate.b - color.b)

	