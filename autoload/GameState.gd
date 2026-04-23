extends Node

enum GameMode { MODE_3D, MODE_2D, MODE_DIALOGUE, MODE_MINIGAME, MODE_UI_ONLY }

# === SOLO DEV PHASE 1: ROLE SYSTEM ===
enum Role { ANALYST, HACKER }
var current_role: Role = Role.ANALYST
var is_campaign_session: bool = false  # Tracks if session started via 'New Campaign'
var role_transition_in_progress: bool = false # Master transition guard

# Hacker role state variables (Phase 2+)
var current_foothold := ""
var hacker_footholds := {}  # hostname -> timestamp
var active_spoof_identity := {} # MAC/IP spoof mask
# =====================================

var current_mode = GameMode.MODE_3D
var current_computer = null
var desktop_instance = null
var active_bridge = null # NEW: Track active 3D monitor bridge
var is_paused: bool = false
var pause_menu_instance: Control = null
var is_guided_mode: bool = false

func _ready():
	# Initial state enforcement
	set_mode(GameMode.MODE_3D)

	# Instantiate pause menu but keep it hidden
	var pause_scene = load("res://scenes/ui/PauseMenu.tscn")
	if pause_scene:
		pause_menu_instance = pause_scene.instantiate()
		get_tree().root.call_deferred("add_child", pause_menu_instance)

func _input(event):
	if event.is_action_pressed("ui_cancel"): # Usually ESC
		# SCENE GUARD: Prevent pausing in menus
		var current_scene = get_tree().current_scene.name
		if current_scene == "MainMenu3D" or current_scene == "TitleScreen":
			return
		
		# Prevent pausing during critical tutorial sequences
		if is_guided_mode:
			if NotificationManager:
				NotificationManager.show_notification("RESTRICTED: Pause menu disabled during active certification.", "warning")
			return
			
		set_paused(!is_paused)

func set_paused(paused: bool):
	is_paused = paused
	get_tree().paused = paused
	
	if pause_menu_instance:
		if paused:
			pause_menu_instance.show_menu()
		else:
			pause_menu_instance.hide_menu()
	
	# PAUSE AUTHORITY: Mouse must be visible when paused
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		_enforce_mouse_mode(current_mode)
	
	print("GameState: Session ", "PAUSED" if paused else "RESUMED")

func set_mode(mode: GameMode):
	current_mode = mode
	_enforce_mouse_mode(mode)
	EventBus.game_mode_changed.emit(mode)

func _enforce_mouse_mode(mode: GameMode):
	match mode:
		GameMode.MODE_3D:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func set_game_mode(mode: GameMode):
	set_mode(mode)

func is_in_3d_mode():
	return current_mode == GameMode.MODE_3D

func is_in_2d_mode():
	return current_mode == GameMode.MODE_2D

func reset_to_default():
	print("GameState: Full system reset for scene change.")
	current_computer = null
	active_bridge = null
	desktop_instance = null
	is_paused = false
	is_guided_mode = false
	
	# Reset Hacker State
	current_foothold = ""
	hacker_footholds.clear()
	active_spoof_identity.clear()
	
	# Reset Managers
	if TraceLevelManager: TraceLevelManager.reset_trace()
	if RivalAI: RivalAI.reset_ai()
	if NarrativeDirector: NarrativeDirector.reset_to_default()
	
	set_mode(GameMode.MODE_3D)

# === SOLO DEV PHASE 1: ROLE SWITCHING ===
func switch_role(new_role: Role) -> bool:
	"""
	Full 11-step role switching sequence.
	Ensures state isolation and system cleanup.
	"""
	# 1. Minigame Guard
	if _is_minigame_active():
		push_warning("GameState: Master Switch BLOCKED (Minigame Active)")
		return false
	
	# 2. Set Dirty Flag
	role_transition_in_progress = true
	
	# 3. Clear All Timers
	if TimeManager:
		TimeManager.clear_all_timers()
	
	# 4. Flush UI Pools
	if EventBus:
		EventBus.flush_ui_pools.emit()
	
	# 5. Switch Network Context
	if NetworkState:
		NetworkState.switch_context(new_role)
	
	# 6. Cache/Reset Heat
	if HeatManager:
		HeatManager.cache_and_reset(new_role)
	
	# 7. Swap Ambient Audio
	if AudioManager:
		AudioManager.swap_ambient_loop(new_role)
	
	# 8. Set Final Role
	current_role = new_role
	print("🛡️ GameState: ROLE_SWITCH COMPLETE -> ", "HACKER" if new_role == Role.HACKER else "ANALYST")
	
	# 9. Variable Reset (Analyst return)
	if new_role == Role.ANALYST:
		current_foothold = ""
		hacker_footholds.clear()
		active_spoof_identity.clear()
	
	# 10. Load UI Theme & Permissions
	if DesktopWindowManager:
		DesktopWindowManager.set_theme(new_role)
	
	# 11. Clear Dirty Flag
	role_transition_in_progress = false
	
	# 12. Global Role Switch Signal
	EventBus.role_switched.emit(new_role)
	
	return true

func _is_minigame_active() -> bool:
	"""Check if any minigame is currently active in the scene tree."""
	# Look for any node of type MinigameBase that is visible
	for node in get_tree().get_nodes_in_group("minigames"):
		if node is Control and node.visible:
			return true
	
	# Fallback: Check if DesktopWindowManager has any open minigame windows
	if DesktopWindowManager and DesktopWindowManager.open_windows:
		for window in DesktopWindowManager.open_windows.values():
			if window and window.visible:
				# Check if window content is a minigame
				if window.has_node("Content") and window.get_node("Content") is Control:
					var content = window.get_node("Content")
					if content.get_script() and content.get_script().resource_path.contains("Minigame"):
						return true
	
	return false
