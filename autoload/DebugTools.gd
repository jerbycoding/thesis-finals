# DebugTools.gd
# Autoload singleton for development/debug utilities
# SOLO DEV PHASE 1: Quick room switching for testing
extends Node

# Debug toggle - set to false to disable all debug features
var debug_enabled: bool = true

# Key bindings (avoiding conflicts with DebugManager.gd)
# DebugManager uses: F1, F2 (shift nav), F7 (chaos), F8-F12 (tutorial/HUD)
# We'll use: F3-F6 for room jumps
const KEY_HACKER_ROOM = KEY_F4      # F4 - Jump to Hacker Room
const KEY_ANALYST_ROOM = KEY_F5     # F5 - Jump to Analyst Room
const KEY_TOGGLE_DEBUG = KEY_F6     # F6 - Toggle Debug Output
const KEY_PRINT_STATE = KEY_F3      # F3 - Print current state

func _ready():
	print("========================================")
	print("DebugTools initialized")
	print("  F3 - Print Current State")
	print("  F4 - Jump to Hacker Room")
	print("  F5 - Jump to Analyst Room (Workstation)")
	print("  F6 - Toggle Debug Output")
	print("========================================")

func _input(event):
	# === ROLE GUARD: Only process input in Hacker campaign ===
	if GameState and GameState.current_role == GameState.Role.ANALYST:
		return  # Skip Hacker debug keys in Analyst campaign
	
	if not debug_enabled:
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		print(">>> DEBUG: Key pressed: ", event.keycode)  # DEBUG: See what key we're getting
		match event.keycode:
			KEY_PRINT_STATE:
				print(">>> DEBUG: F3 detected - Printing state!")  # DEBUG: Confirm F3
				print_role_info()
			KEY_HACKER_ROOM:
				print(">>> DEBUG: F4 detected!")  # DEBUG: Confirm F4
				_jump_to_hacker_room()
			KEY_ANALYST_ROOM:
				print(">>> DEBUG: F5 detected!")  # DEBUG: Confirm F5
				_jump_to_analyst_room()
			KEY_TOGGLE_DEBUG:
				_toggle_debug()

func _jump_to_hacker_room():
	"""F1 - Instant jump to Hacker Room for testing."""
	print(">>> DEBUG: Jumping to Hacker Room (F1)")
	_perform_room_jump(GlobalConstants.SCENES.HACKER_ROOM, GameState.Role.HACKER)

func _jump_to_analyst_room():
	"""F2 - Instant jump to Analyst Room for testing."""
	print(">>> DEBUG: Jumping to Analyst Room (F2)")
	_perform_room_jump(GlobalConstants.SCENES.SOC, GameState.Role.ANALYST)

func _perform_room_jump(scene_path: String, role: GameState.Role):
	"""
	Internal: Perform room jump with proper role setup.
	Skips transition effects for speed.
	"""
	# Set the role
	if GameState:
		GameState.current_role = role
		GameState.is_campaign_session = true
		print(">>> DEBUG: Role set to ", "HACKER" if role == GameState.Role.HACKER else "ANALYST")
	
	# Exit desktop mode if active (cleanup)
	if GameState and GameState.is_in_2d_mode():
		print(">>> DEBUG: Exiting desktop mode...")
		if EventBus:
			EventBus.exit_desktop.emit()
		# Force mode reset
		GameState.set_mode(GameState.GameMode.MODE_3D)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Change scene directly (no transition for speed)
	print(">>> DEBUG: Loading scene: ", scene_path)
	get_tree().change_scene_to_file(scene_path)

func _toggle_debug():
	"""F3 - Toggle debug output on/off."""
	debug_enabled = not debug_enabled
	print(">>> DEBUG: Debug tools ", "ENABLED" if debug_enabled else "DISABLED")

# === UTILITY FUNCTIONS ===

func print_role_info():
	"""Print current role and campaign state to console."""
	if not GameState:
		print(">>> DEBUG: GameState not available")
		return
	
	print(">>> DEBUG: === GAME STATE ===")
	print("  Role: ", "HACKER" if GameState.current_role == GameState.Role.HACKER else "ANALYST")
	print("  Campaign Session: ", GameState.is_campaign_session)
	print("  Current Mode: ", GameState.current_mode)
	print("  In 2D Mode: ", GameState.is_in_2d_mode())
	print("  Current Computer: ", GameState.current_computer)
	print("====================")

func log(message: String, category: String = "DEBUG"):
	"""Conditional debug logging."""
	if debug_enabled:
		print(">>> [%s] %s" % [category, message])
