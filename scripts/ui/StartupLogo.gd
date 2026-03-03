extends Control

@onready var container = %VBoxContainer
@onready var logo_text = %LogoText
@onready var subtitle = %Subtitle
@onready var boot_log = %BootLog
@onready var progress_bar = %ProgressBar
@onready var data_stream = %DataStream
@onready var overlay = %PostProcessOverlay

var is_transitioning = false
var skip_requested = false

const BOOT_LINES = [
	"> INITIALIZING KERNEL...",
	"> LOADING THREAT_DB [v4.2.1]...",
	"> INTEGRITY CHECK: OK",
	"> SOC INTERFACE READY."
]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Initial State
	container.modulate.a = 0
	subtitle.modulate.a = 0
	progress_bar.value = 0
	boot_log.text = ""
	logo_text.text = ""
	
	_run_boot_sequence()

func _input(event):
	if is_transitioning: return
	
	if event is InputEventKey or event is InputEventMouseButton:
		if event.pressed:
			skip_requested = true
			_on_logo_finished()

func _run_boot_sequence():
	# 1. Start with a terminal chirp and fade in container
	if AudioManager: AudioManager.play_terminal_beep(-5.0)
	
	var tween = create_tween()
	tween.tween_property(container, "modulate:a", 1.0, 0.4)
	await tween.finished
	
	if skip_requested: return

	# 2. Rapid Boot Log
	for line in BOOT_LINES:
		boot_log.append_text(line + "\n")
		if AudioManager: AudioManager.play_terminal_beep(-15.0)
		await get_tree().create_timer(0.2).timeout
		if skip_requested: return

	# 3. Logo Typing Effect
	var full_text = " VERIFY.EXE "
	for i in range(full_text.length()):
		logo_text.text += full_text[i]
		if AudioManager: AudioManager.play_terminal_beep(-20.0)
		await get_tree().create_timer(0.04).timeout
		if skip_requested: return

	# 4. Progress Bar Stutter
	var p_tween = create_tween()
	p_tween.tween_property(progress_bar, "value", 40.0, 0.4).set_trans(Tween.TRANS_EXPO)
	p_tween.tween_interval(0.2)
	p_tween.tween_property(progress_bar, "value", 75.0, 0.6).set_trans(Tween.TRANS_QUAD)
	p_tween.tween_property(progress_bar, "value", 100.0, 0.1)
	
	# 5. Fade in Subtitle
	create_tween().tween_property(subtitle, "modulate:a", 1.0, 0.5)
	
	await p_tween.finished
	if skip_requested: return
	
	# Hold for a moment
	await get_tree().create_timer(1.5).timeout
	if skip_requested: return
	
	_on_logo_finished()

func _on_logo_finished():
	if is_transitioning: return
	is_transitioning = true
	
	# Visual "Digital Disintegration"
	var mat = overlay.material as ShaderMaterial
	var tween = create_tween()
	
	# Rapid glitch bursts
	for i in range(5):
		tween.tween_callback(func(): mat.set_shader_parameter("glitch_intensity", randf_range(0.2, 0.5)))
		tween.tween_interval(0.05)
	
	tween.tween_callback(func(): mat.set_shader_parameter("glitch_intensity", 1.0))
	tween.parallel().tween_property(container, "scale:y", 0.0, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(container, "modulate:a", 0.0, 0.2)
	
	# Final fade to black
	tween.tween_property(overlay, "modulate:a", 0.0, 0.1)
	
	await tween.finished
	
	# Hand off to TransitionManager
	if TransitionManager:
		TransitionManager.change_scene_to("res://scenes/3d/MainMenu3D.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/3d/MainMenu3D.tscn")
