extends PanelContainer

signal removal_requested(log_id: String)

@onready var label = %LogIDLabel
@onready var remove_btn = %RemoveButton

var log_id: String = ""

func setup(_log_id: String):
	log_id = _log_id
	label.text = log_id
	remove_btn.pressed.connect(func(): removal_requested.emit(log_id))
