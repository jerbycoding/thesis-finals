# test_npc_animator_diagnostics.gd
extends GdUnitTestSuite

func test_diagnostic_npc_hierarchies():
	var npc_scenes = [
		"res://scenes/3d/NPC_SeniorAnalyst.tscn",
		"res://scenes/3d/NPC_JuniorAnalyst.tscn",
		"res://scenes/3d/NPC_ITSupport.tscn",
		"res://scenes/3d/NPC_Helpdesk.tscn",
		"res://scenes/3d/NPC_Auditor.tscn",
		"res://scenes/3d/NPC_CISO.tscn"
	]
	
	print("\n" + "=".repeat(60))
	print(" NPC ANIMATION DIAGNOSTIC REPORT")
	print("=".repeat(60))
	
	for path in npc_scenes:
		print("\nSCENE: " + path)
		if not FileAccess.file_exists(path):
			print(" -> [ERROR] File does not exist!")
			continue
			
		var scene = load(path)
		var instance = scene.instantiate()
		
		print(" -> FULL HIERARCHY:")
		_print_tree(instance, "    ")
		
		# 1. Check if the root script is BaseNPC
		if instance is BaseNPC:
			print(" -> [OK] Script: BaseNPC detected.")
		else:
			print(" -> [WARN] Script: Root is NOT BaseNPC")
		
		# 2. Check for animator discovery
		var animator = _find_animator_in_node(instance)
		if animator:
			print(" -> [OK] Animator Script: Found on node '%s'" % animator.name)
			var ap = _find_animation_player(animator)
			if ap:
				print(" -> [OK] AnimationPlayer: Found at path '%s'" % animator.get_path_to(ap))
			else:
				print(" -> [ERROR] Animator script cannot find AnimationPlayer child!")
		else:
			print(" -> [ERROR] PlayerAnimator.gd script not found!")
		
		instance.free()
	
	print("\n" + "=".repeat(60))

func _print_tree(node: Node, indent: String):
	print(indent + "- " + node.name + " (" + node.get_class() + ")")
	for child in node.get_children(true):
		_print_tree(child, indent + "  ")

func _find_animator_in_node(node: Node) -> Node:
	if node.has_method("update_movement"):
		return node
	for child in node.get_children(true):
		var found = _find_animator_in_node(child)
		if found: return found
	return null

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer: return node
	for child in node.get_children(true):
		var found = _find_animation_player(child)
		if found: return found
	return null
