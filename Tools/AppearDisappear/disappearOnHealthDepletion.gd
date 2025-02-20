class_name DisappearOnHealthDepletion extends Node

@onready var appear_disappear_node = get_parent().get_node("AppearDisappear") as AppearDisappear
@onready var damage_receiver = get_parent().get_node("DamageReceiver") as DamageReceiver

@export var disappear_on_depleted_health: bool = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready():
	damage_receiver.resource_reached_min.connect(_on_health_depleted)

func _on_health_depleted():
	if disappear_on_depleted_health:
		appear_disappear_node.disappear()
