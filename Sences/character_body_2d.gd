extends CharacterBody2D
class_name Player

const SPEED = 100
@onready var sprite_2d: Sprite2D = $Sprite2D


func _physics_process(delta: float) -> void:
	var hor := Input.get_axis("leftwards", "rightwards")
	var ver := Input.get_axis("upwards", "downwards")
	var direction := Vector2(hor,ver)
	if direction:
		velocity = direction * SPEED
		if Input.is_action_pressed("run"):
			velocity *= 1.8
	else:
		velocity = velocity*0.8
	if velocity.length()<0.01:
		velocity = Vector2.ZERO
	sprite_2d.flip_h = hor<0
	move_and_slide()
