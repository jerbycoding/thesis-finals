extends Control

# AmbientDesktop.gd
# A lightweight version of the desktop for 3D monitor projection.
# purely visual, no gameplay logic.

func _ready():
	# Ensure it renders correctly in the viewport
	z_index = 0
	visible = true
	print("Ambient Desktop initialized")
