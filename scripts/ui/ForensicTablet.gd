extends Control

signal reroute_committed(node_id: String)

@onready var router_list = %RouterList
@onready var commit_btn = %CommitBtn
@onready var status_readout = %StatusReadout

var selected_node: String = ""
var router_data: Dictionary = {} # node_id: {loss: float, status: String}

func _ready():
	commit_btn.disabled = true
	commit_btn.pressed.connect(_on_commit_pressed)
	_initialize_table()

func _initialize_table():
	# Generate randomized technical data for the 2D Audit
	var nodes = ["AUDIT_1", "AUDIT_2", "AUDIT_3", "AUDIT_4", "AUDIT_5", "AUDIT_6"]
	for node in nodes:
		var is_bad = (node == "AUDIT_5") # The known target for now
		router_data[node] = {
			"loss": randf_range(8.0, 15.0) if is_bad else randf_range(0.1, 1.2),
			"status": "ANOMALY" if is_bad else "NOMINAL"
		}
	_refresh_ui()

func _refresh_table_values():
	# Update values slightly to look "live"
	for node in router_data:
		var variance = randf_range(-0.1, 0.1)
		router_data[node].loss = max(0, router_data[node].loss + variance)
	_refresh_ui()

func _refresh_ui():
	for child in router_list.get_children():
		child.queue_free()
	
	for node_id in router_data:
		var h = HBoxContainer.new()
		
		var id_lbl = Label.new()
		id_lbl.text = node_id
		id_lbl.custom_minimum_size.x = 80
		
		var loss_lbl = Label.new()
		loss_lbl.text = "%.2f%% LOSS" % router_data[node_id].loss
		loss_lbl.custom_minimum_size.x = 100
		loss_lbl.add_theme_color_override("font_color", Color.RED if router_data[node_id].loss > 5.0 else Color.GREEN)
		
		var select_btn = Button.new()
		select_btn.text = "SELECT"
		select_btn.toggle_mode = true
		select_btn.button_pressed = (selected_node == node_id)
		select_btn.pressed.connect(_on_node_selected.bind(node_id))
		
		h.add_child(id_lbl)
		h.add_child(loss_lbl)
		h.add_child(select_btn)
		router_list.add_child(h)

func _on_node_selected(node_id: String):
	selected_node = node_id
	commit_btn.disabled = false
	status_readout.text = "HYPOTHESIS: Traffic bottleneck identified at " + node_id
	_refresh_ui()

func _on_commit_pressed():
	if selected_node == "": return
	
	# THE COMMITMENT: Player takes responsibility
	reroute_committed.emit(selected_node)
	
	# Update local 2D state
	router_data[selected_node].loss = 0.05
	router_data[selected_node].status = "NOMINAL"
	selected_node = ""
	commit_btn.disabled = true
	status_readout.text = "CHANGE APPLIED: Traffic rerouted successfully."
	_refresh_ui()
