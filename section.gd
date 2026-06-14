class_name Section extends Control

var color: Color: 
	set(value):
		color = value
		if stylebox: stylebox.bg_color = color

var max_time: float:
	set(value):
		max_time = value
		%Progress.max_value = max_time
		current_time = max_time
var min_time: float:
	set(value):
		min_time = value
		%Progress.min_value = min_time

var current_time: float:
	set(value):
		current_time = value
		update_visuals()

var show_progress: bool = true :
	set(value):
		show_progress = value
		%Progress.visible = show_progress

var stylebox: StyleBoxFlat 
var progressbox: StyleBoxFlat
var current_color: Color = Color.BLACK

func _ready() -> void:
	stylebox = %Panel.get_theme_stylebox("panel").duplicate()
	%Panel.add_theme_stylebox_override("panel",stylebox)
	progressbox = %Progress.get_theme_stylebox("fill").duplicate()
	%Progress.add_theme_stylebox_override("fill",progressbox)
	progressbox.bg_color = current_color

func update_visuals():
	%Progress.value = current_time
	var current_ratio: float = clampf((current_time - min_time) / (max_time - min_time), 0, 1)
	current_color.r = 1 - current_ratio
	progressbox.bg_color = current_color
	if current_ratio <= 0:
		%Panel.hide()
	else:
		%Panel.show()
