# ThreatIntelDossier.gd
extends CanvasLayer

signal acknowledged

@onready var main_container: Control = $Control
@onready var title_label: Label = %TitleLabel
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var impact_label: RichTextLabel = %ImpactLabel
@onready var indicator_list: VBoxContainer = %IndicatorList
@onready var proceed_button: Button = %ProceedButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_shift: ShiftResource = null

func _ready():
	visible = false
	if main_container:
		main_container.modulate.a = 0
	proceed_button.pressed.connect(_on_proceed_pressed)

func setup(shift_res: ShiftResource):
	current_shift = shift_res
	
	if not shift_res:
		push_error("ThreatIntelDossier: Setup called with null resource.")
		return

	# Populate Data
	title_label.text = "THREAT_INTEL :: " + shift_res.threat_title.to_upper()
	
	description_label.text = shift_res.threat_description
	impact_label.text = "[b]OPERATIONAL IMPACT:[/b]
" + shift_res.threat_impact
	
	# Clear and populate indicators
	for child in indicator_list.get_children():
		child.queue_free()
		
	for indicator in shift_res.threat_indicators:
		var lbl = Label.new()
		lbl.text = "> " + indicator
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color(0.2, 0.6, 1.0)) # Cyber Blue
		indicator_list.add_child(lbl)

func show_dossier():
	# If there's no title set, it means this shift doesn't have educational content (e.g. Tutorial)
	# In that case, we auto-acknowledge to skip.
	if not current_shift or current_shift.threat_title.is_empty():
		acknowledged.emit()
		return

	show()
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# High-tech arrival animation
	var tween = create_tween().set_parallel(true)
	tween.tween_property(main_container, "modulate:a", 1.0, 0.5)
	
	if animation_player.has_animation("decrypt_effect"):
		animation_player.play("decrypt_effect")
	
	if AudioManager:
		AudioManager.play_terminal_beep()
		
	proceed_button.grab_focus()

func _on_proceed_pressed():
	if AudioManager:
		AudioManager.play_ui_click()
		
	var tween = create_tween()
	tween.tween_property(main_container, "modulate:a", 0.0, 0.3)
	await tween.finished
	
	acknowledged.emit()
	visible = false
