# ForensicReportModal.gd
extends Control

signal closed

@onready var title_label: Label = %TitleLabel
@onready var results_label: RichTextLabel = %ResultsLabel
@onready var scan_progress: ProgressBar = %ScanProgress
@onready var close_button: Button = %CloseButton
@onready var main_panel: PanelContainer = %MainPanel

func _ready():
	hide()
	close_button.pressed.connect(_on_close_pressed)

func show_report(title: String, technical_data: String):
	title_label.text = ":: " + title.to_upper() + " ::"
	results_label.text = ""
	scan_progress.visible = true
	scan_progress.value = 0
	close_button.disabled = true
	
	show()
	
	# Animate panel in
	modulate.a = 0
	main_panel.scale = Vector2(0.95, 0.95)
	main_panel.pivot_offset = main_panel.size / 2
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.15)
	tween.tween_property(main_panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Simulate Scan
	var scan_tween = create_tween()
	scan_tween.tween_property(scan_progress, "value", 100.0, 0.6)
	await scan_tween.finished
	
	scan_progress.visible = false
	results_label.text = technical_data
	close_button.disabled = false
	close_button.grab_focus()
	
	if AudioManager:
		AudioManager.play_notification("success")

func _on_close_pressed():
	if AudioManager:
		AudioManager.play_ui_click()
	hide()
	closed.emit()

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()
