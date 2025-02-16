extends Node2D

var spell_supplier: SpellSupplier
var player: Player
@export var area2D: Area2D
@export var animation_player: AnimationPlayer
@export var walk_towards: Node2D

enum TutorialState{
	PRESS_E,
	WALK_TOWARDS,
	PRESS_TAB,
	PRESS_ARROW,
	PRESS_SPACE,
}

var current_state = TutorialState.PRESS_E

func _ready():
	animation_player.play("press_e")
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if spell_supplier == null:
		var bodies = area2D.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("SpellSupplier"):
				spell_supplier = body.get_node("SpellSupplier")

	if player == null:
		var bodies = area2D.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("Player"):
				player = body
	
	if spell_supplier == null or player == null:
		return
	

	match current_state:
		TutorialState.PRESS_E:
			visible = spell_supplier.global_position.distance_squared_to(player.global_position) < 2000
			if spell_supplier._activated:
				current_state = TutorialState.WALK_TOWARDS
				animation_player.play("walk_towards")

		
		TutorialState.WALK_TOWARDS:
			visible = walk_towards.global_position.distance_squared_to(player.global_position) < 5000
			if walk_towards.global_position.distance_squared_to(player.global_position) < 100:
				current_state =  TutorialState.PRESS_TAB
				animation_player.play("press_tab")


		TutorialState.PRESS_TAB:
			visible = walk_towards.global_position.distance_squared_to(player.global_position) < 1000
			var targeter = player.get_node("Targeter") as Targeter
			if targeter._lock_on:
				current_state = TutorialState.PRESS_ARROW
				animation_player.play("press_arrows")
				
		
		TutorialState.PRESS_ARROW:
			visible = walk_towards.global_position.distance_squared_to(player.global_position) < 1000	
			if player._active_state == Player.State.SPELLCASTING:
				var key_sequence_recoder = player.get_node("KeySequenceRecoder") as keySequenceRecoder
				if SequenceDecoder._keycodes.has(key_sequence_recoder.get_sequence()):
					if SequenceDecoder._keycodes[key_sequence_recoder.get_sequence()] == load("res://Tools/SpellSystem/Spells/Spells/homingMagicProjectile.tres"):
						current_state = TutorialState.PRESS_SPACE
						animation_player.play("press_space")

		TutorialState.PRESS_SPACE:
			visible = walk_towards.global_position.distance_squared_to(player.global_position) < 1000
			if player._active_state != Player.State.SPELLCASTING:
				self.queue_free()
