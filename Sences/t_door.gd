extends Sprite2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var door_o: Sprite2D = $TDoorO
@onready var door_c: Sprite2D = $TDoorC
@onready var collision_shape_2d: CollisionShape2D = $DoorBody/CollisionShape2D



var open : bool = false :
	set(v):
		trigger(v)
		open = v
var activate : bool = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body = body as Player
		sprite_2d.show()
		activate = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		body = body as Player
		sprite_2d.hide()
		activate = false

func  _input(event: InputEvent) -> void:
	if  event is InputEventKey and activate and event.is_action_pressed("interact"):
		open = true if !open else false

func trigger(openstatus:bool):
	door_o.visible = openstatus
	door_c.visible = !openstatus
	collision_shape_2d.disabled = openstatus
