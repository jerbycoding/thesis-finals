# TimeManager.gd
# Autoload singleton to manage centralized game timers.
# This prevents fire-and-forget timers from causing issues across scene/shift changes.
extends Node

var _timers: Dictionary = {} # id: Timer

func _ready():
	print("TimeManager initialized.")

## Registers and starts a new timer.
## [param id] A unique identifier for the timer.
## [param duration] Time in seconds.
## [param callback] The callable to execute when finished.
func register_timer(id: String, duration: float, callback: Callable):
	# Clean up existing timer with the same ID if it exists
	stop_timer(id)
	
	var timer = Timer.new()
	timer.name = "Timer_" + id.replace("-", "_")
	timer.one_shot = true
	timer.wait_time = max(0.01, duration)
	
	# Connect using a lambda to ensure we can clean up and call back
	timer.timeout.connect(func(): _on_timer_timeout(id, callback, timer))
	
	add_child(timer)
	timer.start()
	
	_timers[id] = timer
	print("TimeManager: Registered timer '%s' for %.1fs" % [id, duration])

func stop_timer(id: String):
	if _timers.has(id):
		var timer = _timers[id]
		if is_instance_valid(timer):
			timer.stop()
			timer.queue_free()
		_timers.erase(id)

func clear_all_timers():
	print("TimeManager: Clearing all active timers (%d)" % _timers.size())
	for id in _timers.keys():
		stop_timer(id)

func get_time_left(id: String) -> float:
	if _timers.has(id):
		var timer = _timers[id]
		if is_instance_valid(timer):
			return timer.time_left
	return 0.0

func _on_timer_timeout(id: String, callback: Callable, timer_node: Timer):
	if not _timers.has(id): return
	
	print("TimeManager: Timer '%s' finished." % id)
	_timers.erase(id)
	
	if callback.is_valid():
		callback.call()
	
	EventBus.timer_finished.emit(id)
	
	# Node cleanup
	if is_instance_valid(timer_node):
		timer_node.queue_free()
