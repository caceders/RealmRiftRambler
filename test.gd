extends Node2D

@onready var animation_player_controller: AnimationPlayer = $AnimationPlayerController
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready():
	animation_player_controller.play("test1")

func switch_anim():	
	animation_player_controller.play("test2")
