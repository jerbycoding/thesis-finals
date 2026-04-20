# App_PhishCrafter.gd
extends Control

@onready var target_dropdown = %TargetDropdown
@onready var launch_button = %LaunchButton
@onready var progress_bar = %CampaignProgress
@onready var log_output = %LogOutput

@onready var invoice_check = %InvoiceCheck
@onready var password_check = %PasswordCheck
@onready var payroll_check = %PayrollCheck

var is_running: bool = false
var selected_hostname: String = ""

func _ready():
	_populate_targets()
	_setup_radio_behavior()
	
	launch_button.pressed.connect(_on_launch_pressed)
	progress_bar.value = 0
	
	# Listen for network changes to update dropdown
	EventBus.host_state_changed.connect(func(_h, _s): _populate_targets())
	
	_log("System ready. Social Engineering modules active.", "gray")

func _populate_targets():
	if not NetworkState: return
	
	target_dropdown.clear()
	var hostnames = NetworkState.get_all_hostnames()
	
	if hostnames.is_empty():
		target_dropdown.add_item("No targets found")
		launch_button.disabled = true
	else:
		hostnames.sort()
		for host in hostnames:
			target_dropdown.add_item(host)
		launch_button.disabled = is_running

func _setup_radio_behavior():
	# Simple mutually exclusive check logic
	invoice_check.toggled.connect(func(b): if b: _clear_checks(invoice_check))
	password_check.toggled.connect(func(b): if b: _clear_checks(password_check))
	payroll_check.toggled.connect(func(b): if b: _clear_checks(payroll_check))

func _clear_checks(active_node: CheckBox):
	for check in [invoice_check, password_check, payroll_check]:
		if check != active_node:
			check.set_pressed_no_signal(false)

func _on_launch_pressed():
	if is_running: return
	
	selected_hostname = target_dropdown.get_item_text(target_dropdown.selected)
	if selected_hostname == "" or selected_hostname == "No targets found":
		return
		
	# Check if already has foothold
	if GameState.hacker_footholds.has(selected_hostname):
		_log("ERROR: Target %s is already compromised." % selected_hostname, "yellow")
		return

	_start_campaign()

func _start_campaign():
	is_running = true
	launch_button.disabled = true
	target_dropdown.disabled = true
	
	var lure = "Urgent Invoice"
	if password_check.button_pressed: lure = "IT Password Reset"
	if payroll_check.button_pressed: lure = "Payroll Update"
	
	_log("\n[b]INITIALIZING CAMPAIGN: %s[/b]" % selected_hostname, "cyan")
	_log("Lure: %s" % lure, "white")
	
	# Visual Progress
	var duration = 4.0 # Match terminal command's feel
	var tween = create_tween()
	progress_bar.value = 0
	tween.tween_property(progress_bar, "value", 100, duration)
	
	# Internal Log Sequence
	_log_sequence([
		"Gathering OSINT data from social profiles...",
		"Crafting spear-phish payload for %s..." % selected_hostname,
		"Bypassing corporate mail filters...",
		"Delivering malicious packet to user mailbox...",
		"Awaiting user interaction (simulating work hours)..."
	], duration)
	
	await tween.finished
	_execute_backend_logic()

func _execute_backend_logic():
	_log("Link clicked! Executing reverse shell payload...", "white")
	await get_tree().create_timer(0.5).timeout
	
	# Reuse TerminalSystem logic for consistency
	var result = await TerminalSystem.execute_command("phish " + selected_hostname)
	
	if result.success:
		_log("\n✓ SUCCESS: %s COMPROMISED" % selected_hostname, "green")
		_log("Foothold established. Access Level: USER", "green")
		if AudioManager: AudioManager.play_notification("success")
	else:
		_log("\n✗ FAILURE: Payload quarantined by security filters.", "red")
		_log("Trace footprint detected. Analyst alert level increased.", "red")
		if AudioManager: AudioManager.play_notification("error")
	
	_finish_campaign()

func _finish_campaign():
	is_running = false
	launch_button.disabled = false
	target_dropdown.disabled = false
	progress_bar.value = 0
	_log("Campaign complete. Ready for next operation.", "gray")

func _log(text: String, color: String = "white"):
	log_output.append_text("[color=%s]%s[/color]\n" % [color, text])

func _log_sequence(lines: Array, total_duration: float):
	var interval = total_duration / lines.size()
	for line in lines:
		await get_tree().create_timer(interval).timeout
		_log("  > " + line, "gray")
