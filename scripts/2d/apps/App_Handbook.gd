# App_Handbook.gd
extends Control

@onready var tab_container = $Panel/VBox/Content/TabContainer

func _ready():
	# Ensure the app is visible when instantiated
	visible = true
	modulate = Color.WHITE
	
	# Default to the first tab
	if tab_container:
		tab_container.current_tab = 0

func show_tab(tab_index: int):
	if tab_container and tab_index < tab_container.get_tab_count():
		tab_container.current_tab = tab_index
