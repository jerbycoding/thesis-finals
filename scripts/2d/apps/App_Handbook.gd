# App_Handbook.gd
extends Control

@onready var reader: RichTextLabel = %Reader
@onready var title_label: Label = %TitleLabel
@onready var nav_buttons: VBoxContainer = %NavButtons

const DOCS = {
	"terminal": {
		"title": "TERMINAL COMMANDS & NETWORK RESPONSE",
		"content": "[b][color=#006CFF]OVERVIEW[/color][/b]\nThe terminal is your primary tool for network-level response.\n\n[b]COMMANDS:[/b]\n• [b]help[/b] - Lists all available forensic modules.\n• [b]scan [hostname][/b] - Performs a host analysis. Required before isolation.\n• [b]trace [ip][/b] - Identifies internal origin host for external traffic.\n• [b]isolate [hostname][/b] - Disconnects host from network.\n\n[b][color=#C62828]WARNING:[/color][/b] Unauthorized isolation of critical servers will trigger a system lockout."
	},
	"network": {
		"title": "NETWORK TOPOLOGY MAPPING",
		"content": "[b][color=#006CFF]VISUALIZATION[/color][/b]\nThe map visualizes organizational assets and real-time status.\n\n[b]INDICATORS:[/b]\n• [color=#2E7D32]Green/Cyan[/color]: Nominal status.\n• [color=#C62828]Red[/color]: Malware infection detected.\n• [color=#F57C00]Orange[/color]: Anomalous activity suspected.\n• [color=#666666]Gray[/color]: Host isolated from network."
	},
	"siem": {
		"title": "SIEM FORENSIC LOG VIEWER",
		"content": "[b][color=#006CFF]EVIDENCE COLLECTION[/color][/b]\nThe SIEM aggregates logs for cross-referenced investigation.\n\n[b]PROCEDURE:[/b]\n1. Select log in the main stream.\n2. Review technical report in the Inspector Pane.\n3. [b]Drag log[/b] onto a ticket in the queue to attach evidence.\n\n[i]Note: Compliant resolution requires all listed evidence IDs to be attached.[/i]"
	},
	"email": {
		"title": "EMAIL THREAT ANALYSIS",
		"content": "[b][color=#006CFF]TRIAGE[/color][/b]\nAnalyze communication headers and artifacts for spoofing.\n\n[b]TOOLS:[/b]\n• [b]Headers[/b]: Verification of SPF/DKIM/DMARC status.\n• [b]Attachments[/b]: Sandbox analysis for executable payloads.\n• [b]Links[/b]: Domain reputation and blacklist verification."
	},
	"procedures": {
		"title": "INCIDENT RESPONSE PROCEDURES (SOP)",
		"content": "[b][color=#006CFF]RESOLUTION STRATEGIES[/color][/b]\n\n• [b]Compliant[/b]: Procedural verification confirmed. Lowest risk posture.\n• [b]Efficient[/b]: Speed priority. High risk of missing hidden consequences.\n• [b]Emergency[/b]: Crisis override. Use only for catastrophic outbreaks."
	},
	"incidents": {
		"title": "INCIDENT CATALOG",
		"content": "[b][color=#006CFF]RECOGNIZED THREATS[/color][/b]\n\n• [b]PHISH-001[/b]: Standard credential harvesting attempt.\n• [b]RANSOM-001[/b]: Host encryption. Requires Decryption module.\n• [b]INSIDER-001[/b]: Unauthorized project data access.\n• [b]DDOS-001[/b]: UDP flood. Requires immediate trace/isolate."
	}
}

func _ready():
	# Connect buttons
	for btn in nav_buttons.get_children():
		if btn is Button:
			var doc_id = btn.name.replace("Btn_", "").to_lower()
			btn.pressed.connect(_show_doc.bind(doc_id))
			btn.mouse_entered.connect(func(): if AudioManager: AudioManager.play_ui_hover())
	
	# Show default doc
	_show_doc("terminal")

func _show_doc(id: String):
	if not DOCS.has(id): return
	
	if AudioManager: AudioManager.play_ui_click()
	
	var doc = DOCS[id]
	title_label.text = ":: " + doc.title + " ::"
	reader.text = doc.content
	
	# Highlight active button
	for btn in nav_buttons.get_children():
		if btn is Button:
			var btn_id = btn.name.replace("Btn_", "").to_lower()
			if btn_id == id:
				btn.add_theme_color_override("font_color", GlobalConstants.UI_COLORS.INFO_BLUE)
			else:
				btn.add_theme_color_override("font_color", GlobalConstants.UI_COLORS.TEXT_PRIMARY)