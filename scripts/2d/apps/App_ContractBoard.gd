# App_ContractBoard.gd
# Phase 4: Hacker campaign contract board UI (Broker Dossier Edition)
extends Control

const ContractResource = preload("res://scripts/resources/ContractResource.gd")

@onready var contract_name = %ContractName
@onready var contract_desc = %ContractDesc
@onready var tactical_hint = %TacticalHint
@onready var intel_block = %IntelBlock
@onready var status_label = %StatusLabel
@onready var accept_button = %AcceptButton
@onready var submit_button = %SubmitButton
@onready var contract_list = %ContractList

var _refresh_timer: Timer = null
var _typing_tween: Tween

func _ready():
	_refresh_contracts()
	
	if submit_button:
		submit_button.pressed.connect(_on_submit_pressed)

	# Set up refresh timer for contract completion detection
	_refresh_timer = Timer.new()
	_refresh_timer.wait_time = 1.0
	_refresh_timer.timeout.connect(_refresh_contracts)
	add_child(_refresh_timer)
	_refresh_timer.start()

func _refresh_contracts():
	"""Update UI based on current contract state."""
	if not ContractManager:
		return

	var active = ContractManager.get_active_contract()

	if active and active.is_accepted:
		# Show active contract
		if contract_name.text != active.title:
			contract_name.text = active.title
			_play_decryption_animation(active.get_formatted_narrative())
		
		# Handle Tactical Intel
		if active.tactical_hint != "":
			tactical_hint.text = active.tactical_hint
			intel_block.visible = true
		else:
			intel_block.visible = false

		if active.is_completed:
			status_label.text = "MISSION_STATUS: [color=green]COMPLETE[/color]"
			status_label.add_theme_color_override("font_color", Color(0, 1, 0, 0.6))
			accept_button.visible = false
			submit_button.visible = false
		else:
			var ready = ContractManager.is_contract_ready(active)
			if ready:
				status_label.text = "MISSION_STATUS: [color=yellow]READY_FOR_UPLOAD[/color]"
				status_label.add_theme_color_override("font_color", Color(1, 1, 0, 0.6))
				submit_button.visible = true
				submit_button.disabled = false
			else:
				status_label.text = "MISSION_STATUS: [color=cyan]IN_PROGRESS[/color]"
				status_label.add_theme_color_override("font_color", Color(0, 1, 1, 0.4))
				submit_button.visible = true
				submit_button.disabled = true
				
			accept_button.visible = false

		# Populate the list with remaining bounties
		_populate_available_contracts(active)
	else:
		# No active contract
		contract_name.text = "// NO_ACTIVE_ASSIGNMENT"
		if contract_desc.text == "":
			contract_desc.text = "Awaiting connection to Broker node. Select a target from the open market below to initialize mission parameters."
		
		intel_block.visible = false
		status_label.text = "CONNECTION_STATUS: [color=gray]STANDBY[/color]"
		accept_button.visible = false
		submit_button.visible = false

		# Show all available contracts
		_populate_available_contracts(null)

func _play_decryption_animation(full_text: String):
	"""Simulates real-time decryption via typing effect."""
	if _typing_tween: _typing_tween.kill()
	
	contract_desc.text = full_text
	contract_desc.visible_ratio = 0.0
	
	_typing_tween = create_tween()
	_typing_tween.tween_property(contract_desc, "visible_ratio", 1.0, 1.5).set_trans(Tween.TRANS_LINEAR)
	
	if AudioManager:
		AudioManager.play_terminal_beep(-15.0)

func _populate_available_contracts(active_contract: ContractResource):
	"""Build data-grid style bounty list."""
	# Clear existing
	for child in contract_list.get_children():
		child.queue_free()

	if not ContractManager:
		return

	var available = ContractManager.get_available_contracts()

	if available.is_empty():
		var label = Label.new()
		label.text = "-- NO_BOUNTIES_LISTED --"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", Color(1, 1, 1, 0.2))
		contract_list.add_child(label)
		return

	for contract in available:
		if active_contract and active_contract.ticket_id == contract.ticket_id:
			continue

		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(0, 70)
		
		# Apply a slight darker style for the market list
		var style = StyleBoxFlat.new()
		style.bg_color = Color(1, 1, 1, 0.03)
		style.border_width_left = 2
		style.border_color = Color(0, 0.8, 0, 0.2)
		panel.add_theme_stylebox_override("panel", style)

		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 15)
		margin.add_theme_constant_override("margin_right", 15)
		panel.add_child(margin)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 20)
		margin.add_child(hbox)

		# ID/Code
		var id_label = Label.new()
		id_label.text = "[ %s ]" % contract.ticket_id.to_upper().substr(0, 8)
		id_label.add_theme_font_size_override("font_size", 10)
		id_label.add_theme_color_override("font_color", Color(0, 1, 0, 0.3))
		hbox.add_child(id_label)

		# Title & Target
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.alignment = VBoxContainer.ALIGNMENT_CENTER
		hbox.add_child(vbox)

		var title_label = Label.new()
		title_label.text = contract.title
		title_label.add_theme_font_size_override("font_size", 15)
		title_label.add_theme_color_override("font_color", Color(0.8, 1, 0.8, 1))
		vbox.add_child(title_label)

		var target_label = Label.new()
		target_label.text = "Target: %s" % (contract.target_hostname if contract.target_hostname != "" else "ANY_NODE")
		target_label.add_theme_font_size_override("font_size", 11)
		target_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
		vbox.add_child(target_label)

		# Bounty
		var bounty_label = Label.new()
		bounty_label.text = "$%d" % contract.bounty_reward
		bounty_label.custom_minimum_size = Vector2(80, 0)
		bounty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		bounty_label.add_theme_font_size_override("font_size", 18)
		bounty_label.add_theme_color_override("font_color", Color(1, 0.8, 0, 0.8))
		hbox.add_child(bounty_label)

		# Accept Button
		var accept_btn = Button.new()
		accept_btn.text = "INITIATE"
		accept_btn.custom_minimum_size = Vector2(100, 35)
		accept_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		accept_btn.pressed.connect(_on_accept_pressed.bind(contract))
		hbox.add_child(accept_btn)

		contract_list.add_child(panel)

func _on_accept_pressed(contract: ContractResource):
	if ContractManager.accept_contract(contract):
		if AudioManager: AudioManager.play_sfx(AudioManager.SFX.notification_info)
		_refresh_contracts()

func _on_submit_pressed():
	var active = ContractManager.get_active_contract()
	if active and ContractManager.submit_contract(active):
		if AudioManager: AudioManager.play_sfx(AudioManager.SFX.notification_success)
		_refresh_contracts()
