extends Button

func set_hostname(name: String, is_server: bool):
	$Hostname.text = name
	if is_server:
		$Icon.text = "🖥️"
		modulate = Color(0.8, 0.8, 1.0) # Slightly brighter for servers
	else:
		$Icon.text = "💻"

func set_status_color(color: Color):
	var style = get_theme_stylebox("normal").duplicate()
	style.border_color = color
	add_theme_stylebox_override("normal", style)
	$Icon.modulate = color
