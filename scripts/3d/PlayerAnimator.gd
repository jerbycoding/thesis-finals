# PlayerAnimator.gd
# Handles character animations with auto-detection for different GLB/FBX naming conventions.
extends Node3D

@export var is_player: bool = false
@export var load_external_actions: bool = true

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

# Discovered actual names for this specific model
var active_idle: String = ""
var active_walk: String = ""
var active_run: String = ""
var active_carry_idle: String = ""
var active_carry_walk: String = ""
var carry_weight: float = 0.0
var _is_carrying_now: bool = false

func _ready():
	# 1. Search locally first (Prioritize the character model the script is on)
	anim_player = _find_node_by_class_recursive(self, "AnimationPlayer")
	skeleton = _find_node_by_class_recursive(self, "Skeleton3D")
	
	# 2. If not found locally, search from parent (Broad Global Search)
	if not anim_player:
		var search_root = get_parent() if get_parent() else self
		anim_player = _find_node_by_class_recursive(search_root, "AnimationPlayer")
		if not skeleton:
			skeleton = _find_node_by_class_recursive(search_root, "Skeleton3D")
	
	if anim_player:
		print("[PlayerAnimator] Found AnimationPlayer: ", anim_player.get_path())
		if load_external_actions:
			_load_external_animations()
		_discover_animations()
		_setup_looping()
		force_idle()
	else:
		push_warning("[PlayerAnimator] WARNING: No AnimationPlayer found for %s" % (owner.name if owner else name))

func _find_node_by_class_recursive(node: Node, class_name_str: String) -> Node:
	if node.get_class() == class_name_str:
		return node
	
	# Search ALL children including internal ones recursively
	for child in node.get_children(true):
		var found = _find_node_by_class_recursive(child, class_name_str)
		if found: return found
			
	return null

func _process(delta):
	# Keep head hidden (animations reset bone scales every frame)
	if skeleton and is_player:
		_hide_head()

	# Smoothly transition the "carry pose" weight
	var target_weight = 1.0 if _is_carrying_now else 0.0
	carry_weight = lerp(carry_weight, target_weight, delta * 8.0)
	
	if carry_weight > 0.01:
		_update_procedural_hands()

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
					if not p.has_animation(internal_name):
						internal_name = "mixamo.com"
					
					if p.has_animation(internal_name):
						var anim = p.get_animation(internal_name)
						library.add_animation(action_name, anim)
				instance.free()
	
	if library.get_animation_list().size() > 0:
		anim_player.add_animation_library("actions", library)
		print("[PlayerAnimator] Loaded %d external actions into 'actions' library" % library.get_animation_list().size())

func _update_procedural_hands():
	if not skeleton or active_carry_idle != "": 
		return
		
	var left_forearm = skeleton.find_bone("LeftForearm")
	if left_forearm == -1: left_forearm = skeleton.find_bone("Forearm.L")
	
	var right_forearm = skeleton.find_bone("RightForearm")
	if right_forearm == -1: right_forearm = skeleton.find_bone("Forearm.R")
	
	var rot_l = Quaternion.from_euler(Vector3(deg_to_rad(-70 * carry_weight), deg_to_rad(30 * carry_weight), 0))
	var rot_r = Quaternion.from_euler(Vector3(deg_to_rad(-70 * carry_weight), deg_to_rad(-30 * carry_weight), 0))
	
	if left_forearm != -1: skeleton.set_bone_pose_rotation(left_forearm, rot_l)
	if right_forearm != -1: skeleton.set_bone_pose_rotation(right_forearm, rot_r)

func _discover_animations():
	active_idle = _find_valid_anim(IDLE_VARIANTS)
	active_walk = _find_valid_anim(WALK_VARIANTS)
	active_run = _find_valid_anim(RUN_VARIANTS)
	active_carry_idle = _find_valid_anim(CARRY_IDLE_VARIANTS)
	active_carry_walk = _find_valid_anim(CARRY_WALK_VARIANTS)
	
	# Fallback to external actions library for Walk/Run
	if active_walk == "" and anim_player.has_animation("actions/Walk"):
		active_walk = "actions/Walk"
	if active_run == "" and anim_player.has_animation("actions/Run"):
		active_run = "actions/Run"
	elif active_run == "" and active_walk != "":
		active_run = active_walk # Use walk as run if no specific run exists

func _find_valid_anim(variants: Array) -> String:
	for v in variants:
		if anim_player.has_animation(v):
			return v
	return ""

func update_movement(velocity: Vector3, is_sprinting: bool, is_carrying: bool = false):
	if not anim_player: return
	
	_is_carrying_now = is_carrying
	var target_anim = active_idle
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	
	if is_carrying and active_carry_idle != "":
		target_anim = active_carry_idle
		if horizontal_speed > 0.1 and active_carry_walk != "":
			target_anim = active_carry_walk
	else:
		if horizontal_speed > 0.1:
			if is_sprinting and active_run != "":
				target_anim = active_run
			elif active_walk != "":
				target_anim = active_walk
	
	if target_anim != "" and anim_player.current_animation != target_anim:
		anim_player.play(target_anim, 0.2)

func play_action(action_name: String, blend: float = 0.2):
	if not anim_player: return
	if anim_player.has_animation("actions/" + action_name):
		anim_player.play("actions/" + action_name, blend)
	elif anim_player.has_animation(action_name):
		anim_player.play(action_name, blend)

func force_idle():
	if anim_player and active_idle != "":
		anim_player.play(active_idle, 0.3)

func _setup_looping():
	# Standard variants
	for anim_name in [active_idle, active_walk, active_run]:
		if anim_name != "" and anim_player.has_animation(anim_name):
			anim_player.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
	
	# Specifically ensure external actions library walk/run also loop
	if anim_player.has_animation("actions/Walk"):
		anim_player.get_animation("actions/Walk").loop_mode = Animation.LOOP_LINEAR
	if anim_player.has_animation("actions/Run"):
		anim_player.get_animation("actions/Run").loop_mode = Animation.LOOP_LINEAR

func _hide_head():
	# Standard and Mixamo naming conventions for head/neck bones
	var head_bones = [
		"Head", "head", "Neck", "neck", 
		"mixamorig_Head", "mixamorig_Neck", 
		"mixamorig_HeadTop_End"
	]
	for bone_name in head_bones:
		var idx = skeleton.find_bone(bone_name)
		if idx != -1:
			skeleton.set_bone_pose_scale(idx, Vector3.ZERO)
		else:
			# Try case-insensitive search if standard fails
			for i in range(skeleton.get_bone_count()):
				var b_name = skeleton.get_bone_name(i).to_lower()
				if "head" in b_name or "neck" in b_name:
					skeleton.set_bone_pose_scale(i, Vector3.ZERO)
