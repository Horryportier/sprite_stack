extends CharacterBody2D

var direction: Vector2 = Vector2(-1, 0)
@export var speed: float = 100
@export var turning_speed: float = 1
@onready var stack: SpriteStack = $SpriteStack
@onready var shape: CollisionShape2D = $CollisionShape2D



func _process(delta: float) -> void:
	if Input.is_action_pressed("forward"):
		velocity = direction * speed * delta
	elif Input.is_action_pressed("backwords"):
		velocity = direction * speed * delta * -1
	else: 
		velocity = lerp(velocity, Vector2.ZERO, 0.7)
	stack.stack_rotation = rad_to_deg((direction * -1).angle())
	shape.rotation = (direction * -1).angle()
	var vel_speed: float = abs(velocity.x) + abs(velocity.y) / 2.

	if Input.is_action_pressed("left") and !velocity.is_zero_approx():
		direction = Vector2.from_angle((direction.angle() + (turning_speed * vel_speed * delta)))
	if Input.is_action_pressed("right") and !velocity.is_zero_approx():
		direction = Vector2.from_angle((direction.angle() - (turning_speed * vel_speed * delta)))
	move_and_collide(velocity)
