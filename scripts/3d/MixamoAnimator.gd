# MixamoAnimator.gd
# Universal base script for all Mixamo characters (NPCs and Player).
# Handles node discovery, root motion fixes, and animation bridging.
extends Node3D
class_name MixamoAnimator

@export var is_player: bool = false
@export var load_external_actions: bool = true
@export var hip_height_override: float = 0.0 # If 0, auto-detects from first frame

# Lists of possible animation names used by different GLB/FBX models
const IDLE_VARIANTS = [
	"mixamo_com", "mixamo.com", "mixamorig|mixamo.com", "Armature|mixamo.com",
	"HumanArmature|Man_Idle", "HumanArmature|Female_Idle", 
	"CharacterArmature|Idle", "CharacterArmature|Idle_Neutral", 
	"CharacterArmature|Idle_Standing", "Armature|Iddle", "Armature|Idle", "Idle"
]
const WALK_VARIANTS = [
	"Walk", "HumanArmature|Man_Walk", "HumanArmature|Female_Walk", 
	"CharacterArmature|Walk", "Armature|Walk"
]
const RUN_VARIANTS = [
	"Run", "HumanArmature|Man_Run", "HumanArmature|Female_Run", 
	"CharacterArmature|Run", "Armature|Run"
]
const CARRY_IDLE_VARIANTS = [
	"CharacterArmature|Interact", "CharacterArmature|Idle_Gun", 
	"HumanArmature|Man_Standing", "Carry_Idle", "Hold_Idle"
]
const CARRY_WALK_VARIANTS = [
	"CharacterArmature|Interact", "CharacterArmature|Walk", "Carry_Walk", "Hold_Walk"
]

var anim_player: AnimationPlayer
var skeleton: Skeleton3D
var initial_pos: Vector3 = Vector3.ZERO

# Discovered actual names for this specific model
var active_idle: String = ""
var active_walk: String = ""
var active_run: String = ""
var active_carry_idle: String = ""
var active_carry_walk: String = ""
var carry_weight: float = 0.0
var _is_carrying_now: bool = false

func _ready():
	# 1. Broad Node Discovery
	_discover_nodes()
	
	if anim_player:
		if load_external_actions and not anim_player.has_animation_library("actions"):
			_load_external_animations()
		
		# Apply technical fixes to ALL animations
		for anim_name in anim_player.get_animation_list():
			_fix_animation_root_motion(anim_player.get_animation(anim_name))
			
		_discover_animations()
		_setup_looping()
		force_idle()
	else:
		push_warning("[%s] WARNING: No character AnimationPlayer found" % name)

func _discover_nodes():
	# Search locally first, then parent
	anim_player = _find_node_by_class_recursive(self, "AnimationPlayer")
	skeleton = _find_node_by_class_recursive(self, "Skeleton3D")
	
	if not anim_player and get_parent():
		for child in get_parent().get_children():
			if child == self: continue
			if "HUD" in child.name or "UI" in child.name or child is CanvasLayer: continue
			anim_player = _find_node_by_class_recursive(child, "AnimationPlayer")
			if anim_player: 
				if not skeleton: skeleton = _find_node_by_class_recursive(child, "Skeleton3D")
				break

func _find_node_by_class_recursive(node: Node, class_name_str: String) -> Node:
	if node.get_class() == class_name_str: return node
	for child in node.get_children(true):
		if "HUD" in child.name or "UI" in child.name or child is CanvasLayer: continue
		var found = _find_node_by_class_recursive(child, class_name_str)
		if found: return found
	return null

func _process(_delta):
	# No longer forcing position/scale here to allow editor control
	pass

func _load_external_animations():
	var anim_dir = "res://assets/Animations Godot/ANIMATION/"
	var library = AnimationLibrary.new()
	var actions = {
		"Walk": "Walking Mark.fbx",
		"Run": "Walking Mark.fbx",
		"Talking": "Talking.fbx",
		"Typing": "Typing.fbx",
		"Victory": "Victory.fbx",
		"Meeting": "Having A Meeting, Male.fbx",
		"Sit_Male": "Sit Male.fbx",
		"Sit_Female": "Sit Female.fbx"
	}
	
	for action_name in actions:
		var path = anim_dir + actions[action_name]
		if FileAccess.file_exists(path):
			var scene = load(path)
			if scene:
				var instance = scene.instantiate()
				var p = _find_node_by_class_recursive(instance, "AnimationPlayer")
				if p:
					var internal_name = "mixamo_com"
					if not p.has_animation(internal_name): internal_name = "mixamo.com"
					if p.has_animation(internal_name):
						var anim = p.get_animation(internal_name).duplicate()
						_fix_animation_root_motion(anim)
						library.add_animation(action_name, anim)
				instance.free()
	
	if library.get_animation_list().size() > 0:
		anim_player.add_animation_library("actions", library)

func _fix_animation_root_motion(anim: Animation):
	if not anim: return
	
	var target_y = hip_height_override
	
	# Auto-detect target hip height from Skeleton Rest Pose if override is not set
	if target_y == 0.0 and skeleton:
		var hip_idx = skeleton.find_bone("Hips")
		if hip_idx == -1: hip_idx = skeleton.find_bone("mixamorig_Hips")
		if hip_idx != -1:
			target_y = skeleton.get_bone_rest(hip_idx).origin.y
	
	# Fallback if no skeleton rest found
	if target_y == 0.0: target_y = 1.0 

	# Find Hips track
	for i in range(anim.get_track_count()):
		var path = str(anim.track_get_path(i))
		if "Hips" in path and anim.track_get_type(i) == Animation.TYPE_POSITION_3D:
			# Lock Hips height to the target to prevent vertical drift (flying/sinking)
			for k in range(anim.track_get_key_count(i)):
				var pos = anim.track_get_key_value(i, k)
				pos.y = target_y 
				anim.track_set_key_value(i, k, pos)
		
		# Disable whole-node translation tracks that cause global drift
		if path.ends_with("Skeleton3D") or path.ends_with("RootNode") or path == ".":
			if anim.track_get_type(i) == Animation.TYPE_POSITION_3D:
				anim.track_set_enabled(i, false)

func _discover_animations():
	active_idle = _find_valid_anim(IDLE_VARIANTS)
	active_walk = _find_valid_anim(WALK_VARIANTS)
	active_run = _find_valid_anim(RUN_VARIANTS)
	active_carry_idle = _find_valid_anim(CARRY_IDLE_VARIANTS)
	active_carry_walk = _find_valid_anim(CARRY_WALK_VARIANTS)
	
	if active_walk == "" and anim_player.has_animation("actions/Walk"): active_walk = "actions/Walk"
	if active_run == "" and anim_player.has_animation("actions/Run"): active_run = "actions/Run"
	elif active_run == "" and active_walk != "": active_run = active_walk

func _find_valid_anim(variants: Array) -> String:
	for v in variants:
		if anim_player.has_animation(v): return v
	return ""

func update_movement(velocity: Vector3, is_sprinting: bool, is_carrying: bool = false):
	if not anim_player: return
	_is_carrying_now = is_carrying
	var target_anim = active_idle
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	
	if is_carrying and active_carry_idle != "":
		target_anim = active_carry_idle
		if horizontal_speed > 0.1 and active_carry_walk != "": target_anim = active_carry_walk
	elif horizontal_speed > 0.1:
		if is_sprinting and active_run != "": target_anim = active_run
		elif active_walk != "": target_anim = active_walk
	
	if target_anim != "" and anim_player.current_animation != target_anim:
		anim_player.play(target_anim, 0.2)

func play_action(action_name: String, blend: float = 0.2):
	if not anim_player: return
	if anim_player.has_animation("actions/" + action_name): anim_player.play("actions/" + action_name, blend)
	elif anim_player.has_animation(action_name): anim_player.play(action_name, blend)

func force_idle():
	if anim_player and active_idle != "": anim_player.play(active_idle, 0.3)

func _setup_looping():
	for anim_name in [active_idle, active_walk, active_run]:
		if anim_name != "" and anim_player.has_animation(anim_name):
			anim_player.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
	if anim_player.has_animation("actions/Walk"): anim_player.get_animation("actions/Walk").loop_mode = Animation.LOOP_LINEAR
	if anim_player.has_animation("actions/Run"): anim_player.get_animation("actions/Run").loop_mode = Animation.LOOP_LINEAR
