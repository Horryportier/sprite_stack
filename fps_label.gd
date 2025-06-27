class_name FpsLabel
extends RichTextLabel

@export_multiline var format: String = "%s"
@export var use_color: bool
@export var gradient: Gradient

func _process(_delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	if use_color:
		var max_fps =  Engine.max_fps if Engine.max_fps > 0 else 60
		text = format % [gradient.sample(remap(fps, 0, max_fps, 0, 1)).to_html(false), fps]
	else:
		text = format % [fps]
