extends Node2D

@onready var entity_sprite: Sprite2D = self.get_parent().get_node("Sprite2D")
@onready var entity = get_parent()

## Should be child of this node
@export var appear_disappear_animation_player : AnimationPlayer
## Should be child of this node
@export var appear_disappear_sprite: Sprite2D
@export var active: bool = true
@export var scene_spawn_on_disappear: PackedScene  # Drag your scene (e.g., Sprite2D) into this field in the editor

func _ready():
	if active:
		appear()
		if entity.has_node("DamageReceiver"):
			var damage_receiver = entity.get_node("DamageReceiver") as DamageReceiver
			damage_receiver.resource_reached_min.connect(disappear)

func _process(delta):
	appear_disappear_sprite.offset = entity_sprite.offset

func appear():
	if active:
		appear_disappear_animation_player.play("entityAppear")

func disappear():
	if active:
		appear_disappear_animation_player.play("entityDisappear")
		await appear_disappear_animation_player.animation_finished
		if scene_spawn_on_disappear:
			var instance = scene_spawn_on_disappear.instantiate() as Node2D # Instantiate the object
			instance.global_position = self.global_position  # Set the object's position to the mouse position
			## Enity parent parent
			get_parent().get_parent().add_child(instance)  # Add the object to the scene tree
		entity.queue_free()
