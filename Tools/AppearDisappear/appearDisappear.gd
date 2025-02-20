class_name AppearDisappear extends Node2D

@onready var entity_sprite: Sprite2D = self.get_parent().get_node("Sprite2D")
@onready var entity = get_parent()

## Should be child of this node
@export var appear_disappear_animation_player : AnimationPlayer
## Should be child of this node
@export var appear_disappear_sprite: Sprite2D
@export var active_appear: bool = true
@export var active_disappear: bool = true

func _ready():
	appear_disappear_sprite.offset = entity_sprite.offset
	if active_appear:
		appear_disappear_animation_player.play("entityAppear")

func _process(delta):
	appear_disappear_sprite.offset = entity_sprite.offset

func disappear():
	if active_disappear:
		appear_disappear_animation_player.play("entityDisappear")
		await appear_disappear_animation_player.animation_finished
		get_parent().queue_free()
