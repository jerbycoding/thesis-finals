# NetworkNode.gd
extends Button

var host_data: HostResource = null

@onready var hostname_label: Label = $Hostname
@onready var icon_label: Label = $Icon

func set_host_data(data: HostResource):
	host_data = data
	if not is_node_ready(): await ready
	
	hostname_label.text = data.hostname
	
	if data.is_critical:
		icon_label.text = "🖥️"
	else:
		icon_label.text = "💻"
		
	_update_visuals()

func _update_visuals():
	if not host_data: return
	
	# Status from NetworkState (dynamic) vs HostResource (static)
	var current_status = GlobalConstants.HOST_STATUS.CLEAN
	if NetworkState:
		var state = NetworkState.get_host_state(host_data.hostname)
		var status_val = state.get("status", "CLEAN")
		
		if typeof(status_val) == TYPE_STRING:
			match status_val:
				"CLEAN": current_status = GlobalConstants.HOST_STATUS.CLEAN
				"SUSPICIOUS": current_status = GlobalConstants.HOST_STATUS.SUSPICIOUS
				"INFECTED": current_status = GlobalConstants.HOST_STATUS.INFECTED
				"ISOLATED": current_status = GlobalConstants.HOST_STATUS.ISOLATED
		else:
			current_status = status_val

	var color = GlobalConstants.UI_COLORS.SUCCESS_FLAT
	match current_status:
		GlobalConstants.HOST_STATUS.CLEAN: color = GlobalConstants.UI_COLORS.SUCCESS_FLAT
		GlobalConstants.HOST_STATUS.INFECTED: color = GlobalConstants.UI_COLORS.ERROR_FLAT
		GlobalConstants.HOST_STATUS.SUSPICIOUS: color = GlobalConstants.UI_COLORS.WARNING_FLAT
		GlobalConstants.HOST_STATUS.ISOLATED: color = Color.GRAY
		
	icon_label.modulate = color
	
	var style = get_theme_stylebox("normal").duplicate()
	style.border_color = color
	if is_hovered():
		style.bg_color = Color(1, 1, 1, 0.1)
	else:
		style.bg_color = Color(0, 0, 0, 0.5)
		
	add_theme_stylebox_override("normal", style)

func set_highlight(active: bool):
	var style = get_theme_stylebox("normal").duplicate()
	if active:
		style.border_width_left = 4
		style.border_width_top = 4
		style.border_width_right = 4
		style.border_width_bottom = 4
		style.border_color = GlobalConstants.UI_COLORS.INFO_BLUE
	else:
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		# color will be reset by _update_visuals next tick or call
	add_theme_stylebox_override("normal", style)
	_update_visuals()