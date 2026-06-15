extends Control


@export var colors: Array[Color]
@export var weights: Array[float]
const SECTION = preload("uid://bxeq5i2b10bnt")
@onready var settings: Settings = %Settings

var max_time: float:
	set(value):
		max_time = value
		setup_colors()
		if current_time > max_time:
			current_time = max_time
		else:
			update_visuals()
var current_time: float:
	set(value):
		current_time = value
		update_visuals()
var total_time: float = 0
var amt_button_presses: int = 0
var sections: Array[Section] = []
var time_per_weight: float
var is_game_over: bool = false

func _ready() -> void:
	restart()
	reset()

func restart():
	is_game_over = false
	%StatusWrapper.show()
	%GameOver.hide()
	%Settings.hide()
	max_time = settings.duration
	total_time = 0
	amt_button_presses = 0
	reset()

func setup_colors():
	var status: Control = %Status
	for child in status.get_children():
		status.remove_child(child)
	sections.clear()
	
	var total_weight: float = weights.reduce(func (total, num): return total+num)
	time_per_weight = max_time / total_weight
	var current_weight: float = 0
	for i in colors.size():
		var color = colors[i]
		var section = SECTION.instantiate() as Section
		status.add_child(section)
		section.color = color
		section.min_time = time_per_weight * current_weight
		current_weight += weights[i]
		section.max_time = time_per_weight * current_weight
		section.show_progress = settings.show_progress
		sections.append(section)

func _process(delta: float) -> void:
	if is_game_over: return
	total_time += delta
	current_time -= delta
	if current_time < 0:
		game_over()

func press_button():
	if is_game_over: return
	if get_tree().paused: return

	if settings.show_popup:
		get_tree().paused = true
		
		for section in sections:
			if section.min_time < current_time and section.max_time > current_time:
				%TeamPopupColor.color = section.color
				break
		%TeamPopup.show()
		await get_tree().create_timer(3).timeout
		get_tree().paused = false
		%TeamPopup.hide()
	reset()
	amt_button_presses += 1

func reset():
	current_time = max_time

func update_visuals():
	for iSection in sections.size():
		var section = sections[iSection]
		section.current_time = current_time

func game_over():
	%StatusWrapper.hide()
	%GameOver.show()
	is_game_over = true
	
	var s: int = int(total_time) % 60
	var m: int = int(total_time / 60) % 60
	var h: int = int(total_time / (60 * 60))
	%GameOverStats.text = "The Button was pressed %s times and kept going for %dh %02dm %02ds" % [amt_button_presses, h, m, s]


func open_settings() -> void:
	get_tree().paused = true
	%SettingsButton.hide()
	settings.show()

func setting_changed(key: String, value: Variant):
	match key:
		"show_progress":
			for section in sections:
				section.show_progress = value
		"duration":
			max_time = value
