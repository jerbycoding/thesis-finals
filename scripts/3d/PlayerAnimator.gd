# PlayerAnimator.gd
# Handles character animations with auto-detection for different GLB naming conventions.
extends Node3D

@export var is_player: bool = false

# Lists of possible animation names used by different GLB models
const IDLE_VARIANTS = [
	"HumanArmature|Man_Idle", "HumanArmature|Female_Idle", 
	"CharacterArmature|Idle", "CharacterArmature|Idle_Neutral", 
	"Armature|Iddle", "Armature|Idle", "Idle"
]
const WALK_VARIANTS = [
	"HumanArmature|Man_Walk", "HumanArmature|Female_Walk", 
	"CharacterArmature|Walk", "Armature|Walk", "Walk"
]
const RUN_VARIANTS = [
	"HumanArmature|Man_Run", "HumanArmature|Female_Run", 
	"CharacterArmature|Run", "Armature|Run", "Run"
]

var anim_player: AnimationPlayer
var skeleton: Skeleton3D

# Discovered actual names for this specific model
var active_idle: String = ""
var active_walk: String = ""
var active_run: String = ""

func _ready():
	anim_player = _find_animation_player(self)
	skeleton = _find_skeleton(self)
	
	if anim_player:
		_discover_animations()
		_setup_looping()
	
	if skeleton and is_player:
		_hide_head()

func _discover_animations():
	active_idle = _find_valid_anim(IDLE_VARIANTS)
	active_walk = _find_valid_anim(WALK_VARIANTS)
	active_run = _find_valid_anim(RUN_VARIANTS)
	
	if active_idle == "":
		print("[PlayerAnimator] Warning: No Idle animation found for ", get_parent().name)

func _find_valid_anim(variants: Array) -> String:
	for v in variants:
		if anim_player.has_animation(v):
			return v
	return ""

func update_movement(velocity: Vector3, is_sprinting: bool):
	if not anim_player: return
	
	var target_anim = active_idle
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	
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
