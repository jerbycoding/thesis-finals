# UIObjectPool.gd
# Generic utility for pooling and reusing UI components to avoid instantiation overhead.
class_name UIObjectPool
extends Node

var _pool: Dictionary = {} # scene_path: Array[Node]
var _active: Dictionary = {} # scene_path: Array[Node]

func _ready():
	# Ensure the pool is cleaned up during role transitions
	if EventBus:
		EventBus.flush_ui_pools.connect(flush)

## Returns an instance of the specified scene, either from the pool or by instantiating.
func acquire(scene: PackedScene) -> Node:
	var path = scene.resource_path
	if not _pool.has(path):
		_pool[path] = []
		_active[path] = []
		
	var node: Node
	if _pool[path].is_empty():
		node = scene.instantiate()
	else:
		node = _pool[path].pop_back()
		
	_active[path].append(node)
	return node

## Returns a node to the pool for later reuse.
func release(node: Node, scene_path: String):
	if not node: return
	
	if node.get_parent():
		node.get_parent().remove_child(node)
		
	if not _pool.has(scene_path):
		_pool[scene_path] = []
		
	_pool[scene_path].append(node)
	
	if _active.has(scene_path):
		_active[scene_path].erase(node)

## Releases all active nodes of a certain type.
func release_all(scene_path: String):
	if not _active.has(scene_path): return
	
	var to_release = _active[scene_path].duplicate()
	for node in to_release:
		release(node, scene_path)

## Cleans up all nodes in the pool (memory management).
func clear_pool(scene_path: String = ""):
	if scene_path == "":
		for p in _pool:
			for node in _pool[p]:
				node.queue_free()
		_pool.clear()
	elif _pool.has(scene_path):
		for node in _pool[scene_path]:
			node.queue_free()
		_pool.erase(scene_path)

## === SOLO DEV PHASE 1: Role Switching Support ===
func flush():
	"""Clear all active pooled UI elements (called during role switch)."""
	for scene_path in _active:
		for node in _active[scene_path]:
			if is_instance_valid(node):
				node.queue_free()
		_active[scene_path].clear()
