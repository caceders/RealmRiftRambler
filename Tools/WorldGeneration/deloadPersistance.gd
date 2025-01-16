class_name DeloadPersistance extends Node

@export var deload_persistant_data: Array[PersistantData]

func _process(_delta):
    for data in deload_persistant_data:
        var subnode = get_parent().get_node(data.node_path)
        data.value = subnode.get(data.property)