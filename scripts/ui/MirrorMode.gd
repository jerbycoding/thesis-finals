# MirrorMode.gd
# The post-shift forensic report (Stage 4 Thesis Piece).
# Shows ground truth (Hacker) vs perception (Analyst) side-by-side.
extends Control

@onready var report_title = %ReportTitle
@onready var hacker_list = %HackerList
@onready var siem_list = %SIEMList
@onready var proceed_button = %ProceedButton

const ENTRY_SCENE = preload("res://scenes/ui/MirrorModeEntry.tscn")

var current_day: int = 1
var correlations: Array = [] # Array of {hacker_node, siem_node, confidence}

func _ready():
	proceed_button.pressed.connect(_on_proceed_pressed)
	set_process(true)
	
	# If current_day is not set externally, try to get from NarrativeDirector
	if NarrativeDirector:
		current_day = NarrativeDirector.current_hacker_day

func _process(_delta):
	# Redraw connectors every frame to handle scrolling
	queue_redraw()

func _draw():
	# Draw correlation lines
	for corr in correlations:
		if not is_instance_valid(corr.hacker_node) or not is_instance_valid(corr.siem_node):
			continue
			
		# Get global positions of the entry centers
		var start_pos = corr.hacker_node.global_position + corr.hacker_node.size / 2.0
		var end_pos = corr.siem_node.global_position + corr.siem_node.size / 2.0
		
		# Convert to local space for drawing
		var inv_trans = get_global_transform().affine_inverse()
		var local_start = inv_trans * start_pos
		var local_end = inv_trans * end_pos
		
		# Line properties based on confidence
		var color = Color(0, 1, 0, 0.4) # Green for high confidence
		var width = 2.0
		
		if corr.confidence == "MEDIUM":
			color = Color(1, 1, 0, 0.3)
			width = 1.5
		elif corr.confidence == "LOW":
			color = Color(1, 0.5, 0, 0.2)
			width = 1.0
			
		draw_line(local_start, local_end, color, width, true)

func show_report(day: int):
	current_day = day
	report_title.text = "FORENSIC CORRELATION: DAY %d" % day
	correlations.clear()
	
	# Clear lists
	for child in hacker_list.get_children(): child.queue_free()
	for child in siem_list.get_children(): child.queue_free()
	
	# Load Hacker History
	var history = []
	var hacker_nodes = []
	if HackerHistory:
		history = HackerHistory.get_entries_for_day(day)
		for entry in history:
			var item = ENTRY_SCENE.instantiate()
			hacker_list.add_child(item)
			item.set_hacker_action(entry)
			hacker_nodes.append(item)
	
	# Load SIEM Logs
	var logs = []
	var siem_nodes = []
	if LogSystem:
		logs = LogSystem.get_logs_for_shift(day)
		for log in logs:
			var item = ENTRY_SCENE.instantiate()
			siem_list.add_child(item)
			item.set_siem_log(log)
			siem_nodes.append(item)
			
	# RUN CORRELATION ENGINE
	_correlate_events(history, hacker_nodes, logs, siem_nodes)
			
	print("📜 MIRROR MODE: Generated report for Day %d (%d hacker actions, %d logs, %d correlations)" % [day, history.size(), logs.size(), correlations.size()])

func _correlate_events(history: Array, h_nodes: Array, logs: Array, s_nodes: Array):
	# Match hacker actions to logs based on timestamp and target
	# THRESHOLD: 5.0 seconds
	const TIME_THRESHOLD = 5.0
	
	for i in range(history.size()):
		var action = history[i]
		var a_time = action.get("timestamp", 0.0)
		var a_target = action.get("target", "").to_upper()
		
		for j in range(logs.size()):
			var log = logs[j]
			var l_time = log.timestamp_seconds
			var l_host = log.hostname.to_upper()
			
			var time_diff = abs(a_time - l_time)
			
			if time_diff <= TIME_THRESHOLD:
				var confidence = "LOW"
				
				# Confidence Tiering
				if l_host == a_target:
					confidence = "HIGH" if time_diff < 1.0 else "MEDIUM"
				elif l_host == "" or a_target == "":
					confidence = "LOW"
				else:
					# Host mismatch but times are close? Possible lateral ripple.
					continue 
				
				correlations.append({
					"hacker_node": h_nodes[i],
					"siem_node": s_nodes[j],
					"confidence": confidence
				})

func _on_proceed_pressed():
	print("📜 MIRROR MODE: Dismiss button pressed.")
	if EventBus:
		EventBus.mirror_mode_closed.emit()
	queue_free()
