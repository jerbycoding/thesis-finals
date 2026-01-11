extends Control

@onready var prompt_container: PanelContainer = %PromptContainer
@onready var label: Label = %Label

func _ready():
	# Start hidden
	modulate.a = 0
	visible = false
	prompt_container.scale = Vector2(0.8, 0.8)

func set_text(text: String):
	if label:
		label.text = text

func show_prompt():
	# Stop any running tweens to avoid conflicts
	var tween_alpha = create_tween()
	var tween_scale = create_tween()
	
	visible = true
	
	# Reset pivot for animation
	prompt_container.pivot_offset = prompt_container.size / 2
	
	# Animate in
	tween_alpha.tween_property(self, "modulate:a", 1.0, 0.2)
	tween_scale.tween_property(prompt_container, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func hide_prompt():
	# Stop any running tweens
	var tween_alpha = create_tween()
	var tween_scale = create_tween()
	
	# Animate out
	tween_alpha.tween_property(self, "modulate:a", 0.0, 0.2)
	tween_scale.tween_property(prompt_container, "scale", Vector2(0.8, 0.8), 0.2)
	
	await tween_alpha.finished
	
	if modulate.a == 0:
		visible = false
