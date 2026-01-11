# shift_timer_hud.gd
extends Control

@onready var timer_label: Label = $TimerLabel

const SHIFT_DURATION = 60.0 # 1 minute for testing

func _ready():
	hide() # Hidden by default
	
	if NarrativeDirector:
		NarrativeDirector.shift_started.connect(_on_shift_started)
		NarrativeDirector.shift_ended.connect(_on_shift_ended)
		
		# If the shift has already started when this HUD is created, show it immediately.
		if NarrativeDirector.is_shift_active():
			_on_shift_started()

func _on_shift_started():
	show()

func _on_shift_ended(results: Dictionary):
	hide()

func _process(delta):
	if not visible:
		return
	
	if NarrativeDirector:
		var time_elapsed = NarrativeDirector.get_shift_timer()
		var time_remaining = max(0, SHIFT_DURATION - time_elapsed)
		
		var minutes = int(time_remaining) / 60
		var seconds = int(time_remaining) % 60
		
		timer_label.text = "Shift Ends In: %02d:%02d" % [minutes, seconds]
		
		# Change color when time is low
		if time_remaining < 60:
			timer_label.add_theme_color_override("font_color", Color.RED)
		elif time_remaining < 300:
			timer_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			timer_label.remove_theme_color_override("font_color")
