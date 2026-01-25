# test_all_npc_animations.gd
extends GdUnitTestSuite

func test_inspect_all_npc_models():
	var models = [
		"res://assets/npc/Animated Woman.glb",
		"res://assets/npc/Business Man.glb",
		"res://assets/npc/Hoodie Character.glb",
		"res://assets/npc/Woman.glb",
		"res://assets/npc/Stylized Character.glb"
	]
	
	print("\n===================================================")
	print(" NPC ANIMATION INSPECTION REPORT")
	print("===================================================")
	
	for path in models:
		print("\nFILE: " + path)
		var scene = load(path)
		if not scene:
			print(" -> ERROR: Could not load file!")
			continue
		
		var instance = scene.instantiate()
		var anim_player = _find_animation_player(instance)
		
		if anim_player:
			var anims = anim_player.get_animation_list()
			if anims.size() == 0:
				print(" -> [EMPTY] No animations found.")
			else:
				for a in anims:
					print(" -> " + a)
		else:
			print(" -> [MISSING] No AnimationPlayer found in scene.")
		
		instance.free()
	
	print("\n===================================================")

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer: return node
	for child in node.get_children():
		var found = _find_animation_player(child)
		if found: return found
	return null
