# App_Ransomware.gd
# Ransomware deployment app with calibration minigame
# Phase 4: High-Impact Payloads
extends Control

# === UI REFERENCES ===
@onready var host_dropdown: OptionButton = $VBox/Content/Margin/FormVBox/Row1/HostDropdown
@onready var ransom_amount_label: Label = $VBox/Content/Margin/FormVBox/Row2/RansomAmount
@onready var deploy_button: Button = $VBox/Content/Margin/FormVBox/DeployButton
@onready var status_label: Label = $VBox/Content/Margin/FormVBox/StatusContainer/StatusLabel
@onready var trace_label: Label = $VBox/Content/Margin/FormVBox/StatusContainer/TraceLabel
@onready var bounty_label: Label = $VBox/Content/Margin/FormVBox/StatusContainer/BountyLabel
@onready var calibration_container: VBoxContainer = $VBox/Content/Margin/FormVBox/CalibrationContainer
@onready var calibration_bar: ColorRect = $VBox/Content/Margin/FormVBox/CalibrationContainer/CalibrationBarContainer/CalibrationBar
@onready var green_zone: ColorRect = $VBox/Content/Margin/FormVBox/CalibrationContainer/CalibrationBarContainer/GreenZone
@onready var calibration_progress_label: Label = $VBox/Content/Margin/FormVBox/CalibrationContainer/CalibrationProgress

# === CONFIGURATION ===
const TRACE_COST = 40.0
const BOUNTY_AMOUNT = 15000.0
const CALIBRATION_REQUIRED = 3
const BAR_SPEED = 1.5

# === STATE ===
var target_host: String = ""
var calibration_successes: int = 0
var is_calibrating: bool = false
var bar_position: float = 0.0
var bar_direction: int = 1
var green_zone_start: float = 0.4
var green_zone_end: float = 0.6

func _ready():
	print("========================================")
	print("App_Ransomware initialized")
	print("  Trace Cost: %.1f" % TRACE_COST)
	print("  Bounty: $%.0f" % BOUNTY_AMOUNT)
	print("========================================")
	
	# Connect UI signals with null checks
	if deploy_button:
		deploy_button.pressed.connect(_on_deploy_button_pressed)
	else:
		push_error("App_Ransomware: deploy_button is NULL! Check scene paths.")
	
	# Populate host dropdown with footholds
	_populate_host_dropdown()

func _populate_host_dropdown():
	"""Add compromised hosts to dropdown."""
	host_dropdown.clear()
	
	# Get footholds from NetworkState
	if NetworkState and NetworkState.has_method("get_footholds"):
		var footholds = NetworkState.get_footholds()
		
		if footholds.is_empty():
			host_dropdown.add_item("No targets available")
			host_dropdown.disabled = true
			_set_status("No compromised hosts", Color(1, 0.3, 0.3, 1))
			return
		
		for host in footholds:
			host_dropdown.add_item(host)
		
		_set_status("READY", Color(0.2, 1, 0.2, 1))
	else:
		host_dropdown.add_item("NetworkState unavailable")
		host_dropdown.disabled = true
		_set_status("Network error", Color(1, 0.3, 0.3, 1))

func _on_deploy_button_pressed():
	"""Start ransomware deployment."""
	if host_dropdown.disabled:
		_set_status("No targets available", Color(1, 0.3, 0.3, 1))
		return
	
	# Get selected host
	var selected_idx = host_dropdown.get_selected_id()
	if selected_idx < 0:
		_set_status("Select a target first", Color(1, 1, 0, 1))
		return
	
	target_host = host_dropdown.get_item_text(selected_idx)
	
	# Start calibration minigame
	_start_calibration()

func _start_calibration():
	"""Initialize calibration minigame."""
	is_calibrating = true
	calibration_successes = 0
	bar_position = 0.0
	bar_direction = 1
	
	# Show calibration UI
	calibration_container.visible = true
	deploy_button.disabled = true
	
	# Calculate green zone based on host vulnerability
	_calculate_green_zone()
	
	_update_calibration_display()
	_set_status("CALIBRATING...", Color(1, 1, 0, 1))

func _calculate_green_zone():
	"""Higher vulnerability = wider green zone."""
	var vulnerability = 0.5  # Default
	
	if NetworkState and NetworkState.has_method("get_host_vulnerability"):
		vulnerability = NetworkState.get_host_vulnerability(target_host)
	
	# Zone width: 10% to 40% based on vulnerability
	var zone_width = 0.1 + (vulnerability * 0.3)
	green_zone_start = 0.5 - (zone_width / 2)
	green_zone_end = 0.5 + (zone_width / 2)
	
	# Update green zone visual
	var bar_width = calibration_bar.get_parent().size.x
	green_zone.position.x = bar_width * green_zone_start
	green_zone.size.x = bar_width * (green_zone_end - green_zone_start)

func _process(delta):
	"""Update calibration bar animation."""
	if not is_calibrating:
		return
	
	# Oscillate bar
	bar_position += BAR_SPEED * bar_direction * delta
	
	if bar_position >= 1.0:
		bar_position = 1.0
		bar_direction = -1
	elif bar_position <= 0.0:
		bar_position = 0.0
		bar_direction = 1
	
	_update_calibration_display()

func _update_calibration_display():
	"""Update calibration bar position."""
	var bar_width = calibration_bar.get_parent().size.x
	calibration_bar.position.x = bar_width * bar_position - 5  # Center bar
	calibration_progress_label.text = "Progress: %d/%d" % [calibration_successes, CALIBRATION_REQUIRED]

func _input(event):
	"""Handle SPACE press for calibration."""
	if not is_calibrating:
		return
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		_check_calibration_hit()

func _check_calibration_hit():
	"""Check if calibration bar is in green zone."""
	if bar_position >= green_zone_start and bar_position <= green_zone_end:
		_on_calibration_success()
	else:
		_on_calibration_fail()

func _on_calibration_success():
	"""Successful calibration hit."""
	calibration_successes += 1
	_update_calibration_display()
	
	# Flash green
	calibration_bar.color = Color(0, 1, 0, 1)
	await get_tree().create_timer(0.2).timeout
	calibration_bar.color = Color(0.2, 0.8, 0.2, 1)
	
	# Check if complete
	if calibration_successes >= CALIBRATION_REQUIRED:
		_complete_deployment()

func _on_calibration_fail():
	"""Missed the green zone."""
	# Flash red
	calibration_bar.color = Color(1, 0, 0, 1)
	await get_tree().create_timer(0.2).timeout
	calibration_bar.color = Color(0.2, 0.8, 0.2, 1)
	
	# Reset progress
	calibration_successes = 0
	_update_calibration_display()
	_set_status("MISSED! Try again...", Color(1, 0.3, 0.3, 1))

func _complete_deployment():
	"""Ransomware successfully deployed."""
	is_calibrating = false
	calibration_container.visible = false
	deploy_button.disabled = false
	
	# Emit signals
	_emit_deployment_signal("SUCCESS")
	
	# Add bounty
	_add_bounty()
	
	# Update UI
	_set_status("✅ DEPLOYED", Color(0, 1, 0, 1))
	
	# Close app after delay
	await get_tree().create_timer(2.0).timeout
	_close_app()

func _on_deployment_failed():
	"""Ransomware deployment failed."""
	is_calibrating = false
	calibration_container.visible = false
	deploy_button.disabled = false
	
	# Still costs trace!
	_emit_deployment_signal("FAILED")
	
	# Update UI
	_set_status("❌ FAILED", Color(1, 0, 0, 1))

func _emit_deployment_signal(result: String):
	"""Emit offensive action signal."""
	if EventBus:
		EventBus.offensive_action_performed.emit({
			"action_type": "ransomware",
			"target": target_host,
			"timestamp": Time.get_unix_time_from_system(),
			"result": result,
			"trace_cost": TRACE_COST,
			"shift_day": 0  # Phase 5: Get from NarrativeDirector
		})

func _add_bounty():
	"""Add bounty to ledger."""
	# Phase 4 Task 2: BountyLedger doesn't exist yet, use safe reference
	var bounty_ledger = get_node_or_null("/root/BountyLedger")
	if bounty_ledger and bounty_ledger.has_method("add_bounty"):
		bounty_ledger.add_bounty(target_host, BOUNTY_AMOUNT)
	else:
		print("💰 BOUNTY: $%.0f from %s" % [BOUNTY_AMOUNT, target_host])

func _set_status(text: String, color: Color):
	"""Update status label."""
	status_label.text = "Status: " + text
	status_label.add_theme_color_override("font_color", color)

func _close_app():
	"""Close this app."""
	if DesktopWindowManager and DesktopWindowManager.has_method("close_app"):
		DesktopWindowManager.close_app("ransomware")
	queue_free()
