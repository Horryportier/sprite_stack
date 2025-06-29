class_name VectorEditField
extends MarginContainer

signal vector_changed(vector: Vector2)

@export var vector: Vector2

@onready var x_field: LineEdit =  %X
@onready var y_field: LineEdit =  %Y
@onready var sync_button: CheckBox =  %SyncCheack

var is_synced: bool = true

func _ready() -> void:
	x_field.text = str(vector.x)
	y_field.text = str(vector.y)
	x_field.text_changed.connect(_on_x_text_changed)
	y_field.text_changed.connect(_on_y_text_changed)
	sync_button.toggled.connect(func (toggled: bool) -> void: is_synced = toggled)
	

func _on_x_text_changed(text: String) -> void:
	if text == "":
		return
	if !text.is_valid_float():
		x_field.text = str(vector.x)
		return
	if is_synced:
		vector = Vector2(float(text), float(text))
		y_field.text = text
	else:
		vector.x = float(text)
	vector_changed.emit(vector)



func _on_y_text_changed(text: String) -> void:
	if text == "":
		return
	if !text.is_valid_float():
		y_field.text = str(vector.y)
		return
	if is_synced:
		vector = Vector2(float(text), float(text))
		x_field.text = text
	else:
		vector.y = float(text)
	vector_changed.emit(vector)
