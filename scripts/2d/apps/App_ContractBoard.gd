# App_ContractBoard.gd
# Phase 4: Hacker campaign contract board UI
# Pattern: @onready var = %NodeName (unique_name_in_owner)
extends Control

const ContractResource = preload("res://scripts/resources/ContractResource.gd")

@onready var contract_name = %ContractName
@onready var contract_desc = %ContractDesc
@onready var status_label = %StatusLabel
@onready var accept_button = %AcceptButton
@onready var submit_button = %SubmitButton
@onready var contract_list = %ContractList

var _refresh_timer: Timer = null

func _ready():
	_refresh_contracts()
	
	if submit_button:
		submit_button.pressed.connect(_on_submit_pressed)

	# Set up refresh timer for contract completion detection
	_refresh_timer = Timer.new()
	_refresh_timer.wait_time = 0.5
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
		contract_name.text = active.title
		contract_desc.text = active.get_formatted_narrative()

		if active.is_completed:
			status_label.text = "STATUS: COMPLETE ✅"
			status_label.add_theme_color_override("font_color", Color(0.3, 1, 0.3, 1))
			accept_button.visible = false
			submit_button.visible = false
		else:
			var ready = ContractManager.is_contract_ready(active)
			if ready:
				status_label.text = "STATUS: READY TO SUBMIT"
				status_label.add_theme_color_override("font_color", Color(0, 1, 0, 1))
				submit_button.visible = true
				submit_button.disabled = false
			else:
				status_label.text = "STATUS: IN PROGRESS"
				status_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
				submit_button.visible = true
				submit_button.disabled = true
				
			accept_button.visible = false

		# Show available contracts below
		_populate_available_contracts(active)
	else:
		# No active contract
		contract_name.text = "No active contract"
		contract_desc.text = "Accept a contract from the available contracts below."
		status_label.text = ""
		accept_button.visible = false
		submit_button.visible = false

		# Show all available contracts
		_populate_available_contracts(null)

func _populate_available_contracts(active_contract: ContractResource):
	"""Build contract list buttons."""
	# Clear existing
	for child in contract_list.get_children():
		child.queue_free()

	if not ContractManager:
		return

	var available = ContractManager.get_available_contracts()

	if available.is_empty():
		var label = Label.new()
		label.text = "No contracts available."
		label.add_theme_color_override("font_color", Color(1, 1, 1, 0.3))
		contract_list.add_child(label)
		return

	for contract in available:
		if active_contract and active_contract.ticket_id == contract.ticket_id:
			continue  # Skip active

		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(600, 80)

		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_bottom", 10)
		panel.add_child(margin)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 15)
		margin.add_child(hbox)

		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(vbox)

		var title_label = Label.new()
		title_label.text = contract.title
		title_label.add_theme_font_size_override("font_size", 16)
		title_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1, 1))
		vbox.add_child(title_label)

		var bounty_label = Label.new()
		bounty_label.text = "Bounty: $%d" % contract.bounty_reward
		bounty_label.add_theme_font_size_override("font_size", 12)
		bounty_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
		vbox.add_child(bounty_label)

		var accept_btn = Button.new()
		accept_btn.text = "ACCEPT"
		accept_btn.custom_minimum_size = Vector2(100, 35)
		accept_btn.pressed.connect(_on_accept_pressed.bind(contract))
		hbox.add_child(accept_btn)

		contract_list.add_child(panel)

func _on_accept_pressed(contract: ContractResource):
	if ContractManager.accept_contract(contract):
		_refresh_contracts()

func _on_submit_pressed():
	var active = ContractManager.get_active_contract()
	if active and ContractManager.submit_contract(active):
		if AudioManager: AudioManager.play_sfx(AudioManager.SFX.notification_success)
		_refresh_contracts()
