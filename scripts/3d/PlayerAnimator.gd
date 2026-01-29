# PlayerAnimator.gd
# Handles character animations with auto-detection for different GLB naming conventions.
extends Node3D

@export var is_player: bool = false

# Lists of possible animation names used by different GLB models
const IDLE_VARIANTS = [
	"HumanArmature|Man_Idle", "HumanArmature|Female_Idle", 
	"CharacterArmature|Idle", "CharacterArmature|Idle_Neutral", 
	"CharacterArmature|Idle_Standing", "Armature|Iddle", "Armature|Idle", "Idle"
]
const WALK_VARIANTS = [
	"HumanArmature|Man_Walk", "HumanArmature|Female_Walk", 
	"CharacterArmature|Walk", "Armature|Walk", "Walk"
]
const RUN_VARIANTS = [
	"HumanArmature|Man_Run", "HumanArmature|Female_Run", 
	"CharacterArmature|Run", "Armature|Run", "Run"
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
	anim_player = _find_animation_player(self)
	skeleton = _find_skeleton(self)
	
	if anim_player:
		_discover_animations()
		_setup_looping()
	
	if skeleton and is_player:
		_hide_head()

func _process(delta):
	# Smoothly transition the "carry pose" weight
	var target_weight = 1.0 if _is_carrying_now else 0.0
	carry_weight = lerp(carry_weight, target_weight, delta * 8.0)
	
	if carry_weight > 0.01:
		_update_procedural_hands()

func _update_procedural_hands():
	if not skeleton or active_carry_idle != "": 
		return # Use animation if we found one
		
	# Find forearm bones (Common naming conventions)
	var left_forearm = skeleton.find_bone("LeftForearm")
	if left_forearm == -1: left_forearm = skeleton.find_bone("left_forearm")
	if left_forearm == -1: left_forearm = skeleton.find_bone("Forearm.L")
	
	var right_forearm = skeleton.find_bone("RightForearm")
	if right_forearm == -1: right_forearm = skeleton.find_bone("right_forearm")
	if right_forearm == -1: right_forearm = skeleton.find_bone("Forearm.R")
	
	# Apply a forward/inward rotation to the forearms only
	# This brings the hands together in front of the chest naturally
	var rot_l = Quaternion.from_euler(Vector3(deg_to_rad(-70 * carry_weight), deg_to_rad(30 * carry_weight), 0))
	var rot_r = Quaternion.from_euler(Vector3(deg_to_rad(-70 * carry_weight), deg_to_rad(-30 * carry_weight), 0))
	
	if left_forearm != -1:
		skeleton.set_bone_pose_rotation(left_forearm, rot_l)
	if right_forearm != -1:
		skeleton.set_bone_pose_rotation(right_forearm, rot_r)

func _discover_animations():
	active_idle = _find_valid_anim(IDLE_VARIANTS)
	active_walk = _find_valid_anim(WALK_VARIANTS)
	active_run = _find_valid_anim(RUN_VARIANTS)
	active_carry_idle = _find_valid_anim(CARRY_IDLE_VARIANTS)
	active_carry_walk = _find_valid_anim(CARRY_WALK_VARIANTS)
	
	if active_idle == "":
		print("[PlayerAnimator] Warning: No Idle animation found for ", get_parent().name)

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

func force_idle():
	if anim_player and active_idle != "":
		anim_player.play(active_idle, 0.3)

func _setup_looping():
	for anim_name in [active_idle, active_walk, active_run]:
		if anim_name != "" and anim_player.has_animation(anim_name):
			anim_player.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR

func _hide_head():
	var head_bones = ["Head", "head", "Neck", "neck"]
	for bone_name in head_bones:
		var idx = skeleton.find_bone(bone_name)
		if idx != -1:
			skeleton.set_bone_pose_scale(idx, Vector3.ZERO)

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer: return node
	for child in node.get_children():
		var found = _find_animation_player(child)
		if found: return found
	return null

func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D: return node
	for child in node.get_children():
		var found = _find_skeleton(child)
		if found: return found
	return null
