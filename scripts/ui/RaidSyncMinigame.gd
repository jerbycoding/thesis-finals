# RaidSyncMinigame.gd
extends "res://scripts/ui/MinigameBase.gd"

@onready var log_text = %LogText
@onready var sync_progress = %SyncProgress
@onready var sync_button = %SyncButton
@onready var disk_grid = %DiskGrid
@onready var status_label = %StatusLabel

var connected_count: int = 0
const REQUIRED_COUNT: int = 4

func _ready():
	minigame_name = "RAID Array Initialization"
	sync_button.pressed.connect(_on_sync_pressed)
	sync_button.disabled = true
	sync_progress.value = 0
	
	# Connect the Disk Buttons in the Grid
	for child in disk_grid.get_children():
		if child is Button:
			child.pressed.connect(_on_node_clicked.bind(child))

func _on_node_clicked(btn: Button):
	if btn.disabled: return
	
	btn.disabled = true
	btn.text = "[ VERIFIED ]"
	btn.add_theme_color_override("font_color", Color("#2E7D32")) # Success Green
	
	connected_count += 1
	
	_add_log("[OK] DISK_NODE_0%d: Integrity verified. Path open." % connected_count)
	if AudioManager: AudioManager.play_terminal_beep()
	
	status_label.text = "VERIFYING_HARDWARE: [%d/%d]" % [connected_count, REQUIRED_COUNT]
	
	if connected_count >= REQUIRED_COUNT:
		sync_button.disabled = false
		status_label.text = "ALL_NODES_ONLINE: READY FOR MASTER SYNC"
		_add_log("[SYSTEM] Hardware handshake complete. Ready for initialization.")

func _on_sync_pressed():
	sync_button.disabled = true
	_add_log("[INIT] MASTER ARRAY SYNC STARTED...")
	
	var tween = create_tween()
	tween.tween_property(sync_progress, "value", 100.0, 2.5).set_trans(Tween.TRANS_SINE)
	
	_add_log_delayed("[RUN] Rebuilding parity map...", 0.5)
	_add_log_delayed("[RUN] Finalizing cluster mirror...", 1.5)
	
	await tween.finished
	_add_log("[SUCCESS] RAID ARRAY OPTIMAL. SHIFT GOAL REACHED.")
	
	if AudioManager: AudioManager.play_sfx(AudioManager.SFX.notification_success)
	
	await get_tree().create_timer(1.0).timeout
	_on_win({"type": "RAID_REBUILD", "nodes": connected_count})

func _add_log(msg: String):
	log_text.append_text("\n" + msg)

func _add_log_delayed(msg: String, delay: float):
	if is_instance_valid(self):
		get_tree().create_timer(delay).timeout.connect(func(): _add_log(msg))
