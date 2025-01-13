@tool
class_name Vision extends Area2D
@export var distance = 100:
	set(value):
		if value < 0: distance = 0
		else: distance = value
		
signal body_entered_sight
signal body_exited_sight

func _ready():
	body_entered.connect(_on_body_entered_area)
	body_exited.connect(_on_body_exited_area)

func _physics_process(_delta):
	if $CollisionShape2D.shape.radius != distance:
		var shape = CircleShape2D.new()
		shape.radius = distance
		$CollisionShape2D.shape = shape
	return

func get_bodies_in_sight():
	var bodies = super.get_overlapping_bodies()
	var seen_bodies = []
	for body in bodies:
		if not "Invisible" in body.get_groups():
			seen_bodies.append(body)
	return seen_bodies

func _on_body_entered_area(body):
	if not "Invisible" in body.get_groups():
		body_entered_sight.emit(body)

func _on_body_exited_area(body):
	if not "Invisible" in body.get_groups():
		body_exited_sight.emit(body)
