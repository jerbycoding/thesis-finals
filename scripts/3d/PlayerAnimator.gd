# PlayerAnimator.gd
# Specialized animator for the Player character.
# Inherits universal Mixamo fixes and adds First-Person features.
extends MixamoAnimator

# Additional procedural animation weights
var _hand_sync_weight: float = 0.0

func _ready():
	is_player = true # Force player flag for this subclass
	super._ready() # Call the universal discovery and fix logic

func _process(delta):
	super._process(delta) # Maintain grounding fix
	
	# Handle First-Person Head Hiding
	if skeleton:
		_hide_head()

	# Smoothly transition procedural hand positions
	var target_weight = 1.0 if _is_carrying_now else 0.0
	carry_weight = lerp(carry_weight, target_weight, delta * 8.0)
	
	if carry_weight > 0.01:
		_update_procedural_hands()

func _update_procedural_hands():
	# Inherit bone mapping from parent or local logic
	if not skeleton or active_carry_idle != "": 
		return
		
	var left_forearm = skeleton.find_bone("LeftForearm")
	if left_forearm == -1: left_forearm = skeleton.find_bone("Forearm.L")
	if left_forearm == -1: left_forearm = skeleton.find_bone("mixamorig_LeftForearm")
	
	var right_forearm = skeleton.find_bone("RightForearm")
	if right_forearm == -1: right_forearm = skeleton.find_bone("Forearm.R")
	if right_forearm == -1: right_forearm = skeleton.find_bone("mixamorig_RightForearm")
	
	var rot_l = Quaternion.from_euler(Vector3(deg_to_rad(-70 * carry_weight), deg_to_rad(30 * carry_weight), 0))
	var rot_r = Quaternion.from_euler(Vector3(deg_to_rad(-70 * carry_weight), deg_to_rad(-30 * carry_weight), 0))
	
	if left_forearm != -1: skeleton.set_bone_pose_rotation(left_forearm, rot_l)
	if right_forearm != -1: skeleton.set_bone_pose_rotation(right_forearm, rot_r)

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
			# Recursive search for any bone containing 'head' or 'neck'
			for i in range(skeleton.get_bone_count()):
				var b_name = skeleton.get_bone_name(i).to_lower()
				if "head" in b_name or "neck" in b_name:
					skeleton.set_bone_pose_scale(i, Vector3.ZERO)
