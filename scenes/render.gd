extends Node


@onready var subviewport: SubViewport = %SubViewport
@onready var sprite_stack: SpriteStack = %SpriteStack
@onready var subviewport_container: SubViewportContainer = %RenderingContainer
@onready var camera: Camera2D = %MainCamera

# ui nodes
@onready var zoom_in_button: TextureButton = %ZoomInButton
@onready var zoom_out_button: TextureButton = %ZoomOutButton
@onready var zoom_rect: ColorRect = %ZoomRect

@onready var reset_transform_button: TextureButton = %ResetTransform
@onready var left: TextureButton = %Left
@onready var pause: TextureButton = %Pause
@onready var right: TextureButton = %Right

@onready var file_select: TextureButton = %FileSelect
@onready var file_dialog: FileDialog = %FileDialog

@onready var h_frames: LineEdit = %Hframes
@onready var spacing: LineEdit = %Spacing

@onready var save_button: TextureButton = %SaveButton
@onready var save_incremental_button: CheckButton = %SaveIncremental
@onready var custom_rotation: LineEdit = %Rotation
@onready var increments: LineEdit = %Increments

@onready var asepriet_path_line_edit: LineEdit = %AsepritePath
@onready var background_color_button: ColorPickerButton = %BackgroundColorButton

@export_group("ui")
@export var zoom_speed: float = 0.001 
@export var rotation_speed: float = 1
@export_group("setup")
@export var sprite_stack_rotation: float = 0 
@export var sprite_stack_rotation_increments: float = 15
@export var save_incremental: bool = false
@export var clear_output: bool


const DEFAULT_ASEPRITE_PATH: String = "aseprite"

@export var aseprite_path: String = DEFAULT_ASEPRITE_PATH


const CENTER_POSITION: Vector2 = Vector2(0.5, 0.5)
const DEFAULT_ZOOM: float  = -0.145

@export_group("export")
@export var output_path: String

var current_angle: float

var saved_paths: Array[String]

var is_spining_on: bool = false

func _ready() -> void:
	align()
	asepriet_path_line_edit.text = DEFAULT_ASEPRITE_PATH
	asepriet_path_line_edit.text_changed.connect(_on_custom_aseprite_text_chnaged)
	pause.toggled.connect(func (toggled: bool) -> void: is_spining_on = toggled)
	left.pressed.connect(func () -> void: sprite_stack.stack_rotation += rotation_speed)
	right.pressed.connect(func () -> void: sprite_stack.stack_rotation -= rotation_speed)
	file_select.pressed.connect(func () -> void: file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE; file_dialog.show())
	file_dialog.file_selected.connect(_on_file_selected)
	h_frames.text_changed.connect(_on_h_frames_text_changed)
	spacing.text_changed.connect(_on_spacing_text_changed)
	save_incremental_button.toggled.connect(func (toggled: bool) -> void: save_incremental = toggled)
	save_incremental = save_incremental_button.toggle_mode
	save_button.pressed.connect(func () -> void: file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE; file_dialog.show())
	custom_rotation.text_changed.connect(_on_custom_rotation_text_changed)
	increments.text_changed.connect(_on_increments_text_changed)
	background_color_button.color_changed.connect(_on_background_color_changed)
	reset_transform_button.pressed.connect(_on_reset_transform_pressed)

func save_by_angle(path: String) -> void:
	align()
	print(save_incremental)
	sprite_stack.stack_rotation = 0
	if save_incremental:
		for i: int in 360 / sprite_stack_rotation_increments:
			var frame_path = "%sframe_%s.png" % [output_path, i]
			await save(frame_path)
			current_angle += sprite_stack_rotation_increments
			sprite_stack.stack_rotation = current_angle
			await get_tree().create_timer(0.2).timeout
		current_angle = 0
		await get_tree().create_timer(1).timeout
		sprite_sheet(path)
		await get_tree().create_timer(2).timeout
		if clear_output:
			_clean_output()


	else:
		sprite_stack.stack_rotation = sprite_stack_rotation
		save(path)

func _physics_process(delta: float) -> void:
	if is_spining_on:
		sprite_stack.stack_rotation += rotation_speed * delta

	if zoom_in_button.button_pressed:
		zoom_rect.material.set("shader_parameter/zoom_amount", clamp(zoom_rect.material.get("shader_parameter/zoom_amount") + zoom_speed, -1, -0.05))
	if zoom_out_button.button_pressed:
		zoom_rect.material.set("shader_parameter/zoom_amount", clamp(zoom_rect.material.get("shader_parameter/zoom_amount")- zoom_speed, -1, -0.05))
	
func align() -> void:
	@warning_ignore("integer_division")
	var long_side: float = max(sprite_stack.texture.get_width() / sprite_stack.hframes, sprite_stack.texture.get_height())
	@warning_ignore("integer_division")
	subviewport.size = Vector2(long_side , long_side) + Vector2(0, sprite_stack.hframes / 2)
	@warning_ignore("integer_division")
	sprite_stack.global_position = subviewport.size * 0.5 + Vector2(0, sprite_stack.hframes / 2)
	camera.global_position = subviewport.size * 0.5

func save(path: String) -> void:
	await  RenderingServer.frame_post_draw
	var texture: = subviewport.get_texture()
	var image: = texture.get_image()
	image.convert(Image.FORMAT_RGBA8)
	image.save_png(path)


func _clean_output() -> void:
	var paths: = DirAccess.get_files_at(output_path)
	var dir: = DirAccess.open(output_path)
	for path in paths:
		if path.ends_with(".png"):
			dir.remove(path)

func sprite_sheet(sprite_sheet_save_path: String) -> void:
	var paths: = DirAccess.get_files_at(output_path)
	var args: PackedStringArray 
	var save_path_trimed: = output_path.trim_prefix("res://")
	for path in paths:
		if path.ends_with(".png"):
			args.append(save_path_trimed + path)
	args.append("--sheet=%s" % [sprite_sheet_save_path])
	#print_rich("[color=red]%s" %[args] )
	var dir: Dictionary = OS.execute_with_pipe(aseprite_path if aseprite_path != "" else DEFAULT_ASEPRITE_PATH, args)
	await get_tree().create_timer(2).timeout
	if dir.has("pid"):
		OS.kill(dir["pid"])
	

func _on_file_selected(path: String) -> void:
	match file_dialog.file_mode:
		FileDialog.FILE_MODE_SAVE_FILE:
			_save_file(path)
		FileDialog.FILE_MODE_OPEN_FILE:
			_load_file(path)
	
func _load_file(path: String) -> void:
	if !path.ends_with(".png"):
		push_warning("path is not an [.png]: ", path)
		return
	print(path)
	var image: = Image.load_from_file(path)
	var texture: = ImageTexture.create_from_image(image)
	sprite_stack.texture = texture
	sprite_stack._update_sprite_stack()

func _save_file(path: String) -> void:
	if !path.ends_with(".png"):
		push_warning("path is not an [.png]: ", path)
		return
	is_spining_on = false
	pause.button_pressed = false
	save_by_angle(path)

func _on_h_frames_text_changed(new_text: String) -> void:
	if new_text == "":
		return
	if !new_text.is_valid_int():
		h_frames.text = str(sprite_stack.hframes)
		return
	sprite_stack.hframes = int(new_text)
	sprite_stack._update_sprite_stack()
	align()
	
func _on_spacing_text_changed(new_text: String) -> void:
	if new_text == "":
		return
	if !new_text.is_valid_float():
		spacing.text = str(sprite_stack.spacting)
		return
	sprite_stack.spacting = float(new_text)
	sprite_stack._update_sprite_stack()
	
func _on_custom_rotation_text_changed(new_text: String) -> void:
	if new_text == "":
		return
	if !new_text.is_valid_float():
		custom_rotation.text = str(sprite_stack_rotation)
		return
	sprite_stack_rotation = float(new_text)

func _on_custom_aseprite_text_chnaged(new_text: String) -> void:
	if new_text == "":
		return
	if !new_text.is_valid_filename():
		asepriet_path_line_edit.text = DEFAULT_ASEPRITE_PATH
		return
	aseprite_path = new_text

func _on_increments_text_changed(new_text: String) -> void:
	if new_text == "":
		return
	if !new_text.is_valid_float():
		increments.text = str(sprite_stack_rotation_increments)
		return
	sprite_stack_rotation_increments = float(new_text)

func _on_background_color_changed(color: Color) -> void:
	RenderingServer.set_default_clear_color(color)

func _on_reset_transform_pressed() -> void:
	zoom_rect.material.set("shader_parameter/zoom_amount", DEFAULT_ZOOM)
	zoom_rect.material.set("shader_parameter/zoom_center", CENTER_POSITION)
