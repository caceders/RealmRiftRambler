class_name LineSpellComponent extends SpellComponent

## DEPRECATED - since spellcomponents are copied the remove line function is never called.

@export var line_existance_time: float = .2
@export var line_thickness: float = 1
@export var line_color: Color = Color.RED
var _timer: Timer
var _line: Line2D

func activate(spell_caster: SpellCaster):
	if spell_caster.parent == null or spell_caster.target == null:
		return
	_timer = Timer.new()
	_timer.timeout.connect(remove_line)
	spell_caster.parent.add_child(_timer)
	_line = Line2D.new()
	var parent: Node2D = spell_caster.parent as Node2D
	var target: Node2D = spell_caster.target as Node2D
	var offset_parent = Vector2(0, 0)
	var offset_target = Vector2(0, 0)
	var parent_sprite = parent.get_node("Sprite2D") as Sprite2D
	var target_sprite = target.get_node("Sprite2D") as Sprite2D
	if parent_sprite != null:
		offset_parent.x = (parent_sprite.texture.get_size().x / 2) + parent_sprite.offset.x
		offset_parent.y = - (parent_sprite.texture.get_size().y / 2) - parent_sprite.offset.y
	if target_sprite != null:
		offset_target.x = (target_sprite.texture.get_size().x / 2) + target_sprite.offset.x
		offset_target.y = - (target_sprite.texture.get_size().y / 2) - target_sprite.offset.y
	_line.add_point(Vector2(0,0))
	_line.add_point((target.position + offset_target) - (parent.position + offset_parent))
	_line.default_color = line_color
	_line.width = line_thickness
	_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	spell_caster.parent.add_child(_line)
	_timer.one_shot = true
	_timer.start(line_existance_time)
		
		
func remove_line():
	_line.queue_free()
	_timer.queue_free()