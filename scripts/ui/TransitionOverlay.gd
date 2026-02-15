extends CanvasLayer

signal fade_finished

@onready var title_label: Label = get_node_or_null("TitleLabel")
@onready var login_container = %LoginContainer

func set_title_card(text: String):
	if title_label:
		title_label.text = text
		title_label.visible = !text.is_empty()

func fade_in():
	show()
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	
	if title_label and title_label.visible:
		await get_tree().create_timer(2.0).timeout

	fade_finished.emit()

func fade_out():
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	hide()
	fade_finished.emit()

# POLISH: Screen Shake Effect
func shake_screen(intensity: float = 10.0, duration: float = 0.2):
	var original_pos = login_container.position
	var tween = create_tween()
	
	for i in range(5):
		var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(login_container, "position", original_pos + offset, duration / 5.0)
	
	tween.tween_property(login_container, "position", original_pos, duration / 5.0)

# POLISH: Visual Flash
func flash_green():
	var flash = ColorRect.new()
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(0, 1, 0, 0.1)
	add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.3)
	await tween.finished
	flash.queue_free()