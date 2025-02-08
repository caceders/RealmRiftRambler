class_name ResourceDropSpawnOnDeath extends Node

@export var health: DamageReceiver
@export var resource_drop_spawn: ResourceDropSpawn

func _ready():
	if health != null and resource_drop_spawn != null:
		health.resource_reached_min.connect(resource_drop_spawn.drop)