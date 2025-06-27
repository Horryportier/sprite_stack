@tool
class_name SpriteStack
extends CanvasGroup

@export var texture: Texture2D
@export var hframes: int
@export var spacting: float
@export_range(-360, 360) var stack_rotation: float:
	set(val):
		stack_rotation = val
		_update_stack_rotation()
@export_tool_button("UPDATE", "Callable") var update: Callable = _update_sprite_stack


func _ready() -> void:
	_update_sprite_stack()


func _update_sprite_stack() -> void:
	for child in get_children():
		child.queue_free()
	for idx in hframes:
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.hframes = hframes
		sprite.frame = idx
		sprite.position.y = -(idx * spacting)
		add_child(sprite)

func _update_stack_rotation() -> void:
	for child: Sprite2D in get_children():
		child.rotation = deg_to_rad(stack_rotation)
