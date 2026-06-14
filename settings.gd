class_name Settings extends Control

signal setting_changed(setting_name: String, value: Variant)

var show_popup: bool = true:
	set(value):
		show_popup = value
		%ShowPopup.button_pressed = value
var show_progress: bool = true:
	set(value):
		show_progress = value
		%ShowProgress.button_pressed = value
var duration: float = 10:
	set(value):
		duration = value
		%Hours.value = hours
		%Minutes.value = minutes
		%Seconds.value = seconds

var hours: int:
	set(value):
		set_duration(seconds, minutes, value)
	get():
		return int(duration / (60 * 60))
		
var minutes: int:
	set(value):
		set_duration(seconds, value, hours) 
	get():
		return int(duration / 60) % 60

var seconds: int:
	set(value):
		set_duration(value, minutes, hours)
	get():
		return int(duration) % 60

func _ready() -> void:
	duration = 10 * 60;
	show_progress = true
	show_popup = true

func set_duration(s, m, h) -> void:
	duration = s + m * 60 + h * 60 * 60

func close_settings() -> void:
	get_tree().paused = false
	%SettingsButton.show()
	%Settings.hide()
	setting_changed.emit("duration", duration)
	

func set_setting(value: Variant, _name: String):
	set(_name, value)
	setting_changed.emit(_name, value)
