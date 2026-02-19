# WarWall.gd
# Manages the high-fidelity data display in the Incident War Room.
# Displays real-time organizational metrics and threat status.
extends Label3D

@export var update_interval: float = 1.5
var _time_since_update: float = 0.0

func _ready():
	# Initial update
	_update_display()

func _process(delta):
	_time_since_update += delta
	if _time_since_update >= update_interval:
		_time_since_update = 0.0
		_update_display()
	
	# Add a slight "digital flicker" effect
	if randf() < 0.02:
		modulate.a = randf_range(0.7, 1.0)
	else:
		modulate.a = lerp(modulate.a, 1.0, delta * 10.0)

func _update_display():
	var integrity = 100.0
	if IntegrityManager:
		integrity = IntegrityManager.current_integrity
		
	var heat = 1.0
	if HeatManager:
		heat = HeatManager.heat_multiplier
		
	var active_count = 0
	var critical_count = 0
	if TicketManager:
		var tickets = TicketManager.active_tickets
		active_count = tickets.size()
		for t in tickets:
			if t.severity.to_lower() == "critical":
				critical_count += 1
				
	# Build the technical readout string
	var text_output = ""
	text_output += "[ SYSTEM STATUS ]\n"
	text_output += "INTEGRITY: %d%%\n" % int(integrity)
	text_output += "THREAT LEVEL: %.2fx\n" % heat
	text_output += "------------------\n"
	text_output += "[ INCIDENT QUEUE ]\n"
	text_output += "ACTIVE: %d\n" % active_count
	text_output += "CRITICAL: %d\n" % critical_count
	text_output += "------------------\n"
	
	# Status message based on integrity
	if integrity <= 20:
		text_output += "!!! CRITICAL FAILURE IMMINENT !!!"
		outline_render_priority = 1
		outline_modulate = Color.RED
	elif integrity <= 50:
		text_output += "STATUS: UNSTABLE - DEGRADED"
		outline_modulate = Color.ORANGE
	elif critical_count > 0:
		text_output += "STATUS: ACTIVE ENGAGEMENT"
		outline_modulate = Color.YELLOW
	else:
		text_output += "STATUS: OPERATIONAL - SECURE"
		outline_modulate = Color.CYAN
		
	text = text_output
