extends Node

## EnvironmentDirector.gd
## Manages 3D office atmosphere based on the organization's Integrity.

@export var environment_node: WorldEnvironment
@export var light_group: Node3D # Parent of the SpotLights
@export var flicker_enabled: bool = true

var initial_energy: float = 1.0
var initial_ambient_energy: float = 0.2
var initial_colors: Dictionary = {} # light_name -> color

func _ready():
	if environment_node:
		initial_ambient_energy = environment_node.environment.ambient_light_energy
	
	if light_group:
		for light in light_group.get_children():
			if light is Light3D:
				initial_colors[light.name] = light.light_color
				initial_energy = light.light_energy # Assuming all lights have similar base energy
	
	if IntegrityManager:
		IntegrityManager.integrity_changed.connect(_on_integrity_changed)
		_on_integrity_changed(IntegrityManager.current_integrity, 0.0)
	
	print("EnvironmentDirector: Initialized. Monitoring Integrity...")

func _process(_delta):
	# Flickering logic for low integrity
	if flicker_enabled and IntegrityManager and IntegrityManager.current_integrity < 35.0:
		var target_energy = _get_target_energy(IntegrityManager.current_integrity)
		
		# High frequency jitter
		var flicker = randf_range(0.4, 1.1)
		
		# Rare "Blackout" flicker
		if randf() > 0.98:
			flicker = 0.0
			
		if light_group:
			for light in light_group.get_children():
				if light is Light3D:
					light.light_energy = flicker * target_energy

func _on_integrity_changed(new_integrity: float, _delta: float):
	var percent = new_integrity / 100.0
	
	# Determine target color based on integrity stages
	var target_color = Color(1.0, 1.0, 1.0) # Default White
	
	if percent > 0.75:
		# STABLE: Clinical White
		target_color = Color(0.9, 0.95, 1.0) 
	elif percent > 0.4:
		# WARNING: Warm Yellow/Orange
		var t = (percent - 0.4) / 0.35 # 0 to 1
		target_color = Color(1.0, 0.8, 0.4).lerp(Color(0.9, 0.95, 1.0), t)
	else:
		# CRISIS: Emergency Red
		var t = percent / 0.4
		target_color = Color(1.0, 0.1, 0.05).lerp(Color(1.0, 0.8, 0.4), t)
	
	var target_energy = _get_target_energy(new_integrity)
	
	# Apply to lights via Tween for smoothness
	if light_group:
		var tween = create_tween().set_parallel(true)
		for light in light_group.get_children():
			if light is Light3D:
				tween.tween_property(light, "light_color", target_color, 2.0)
				# Only tween energy if not in flicker range (to avoid combatting _process)
				if percent >= 0.35:
					tween.tween_property(light, "light_energy", target_energy, 2.0)
					
	# Apply to environment ambient/fog
	if environment_node:
		var tween = create_tween().set_parallel(true)
		var ambient_energy = lerp(0.02, initial_ambient_energy, percent)
		
		tween.tween_property(environment_node.environment, "ambient_light_energy", ambient_energy, 2.0)
		tween.tween_property(environment_node.environment, "ambient_light_color", target_color, 2.0)
		
		# Increase fog density in crisis
		var fog_density = lerp(0.04, 0.005, percent)
		tween.tween_property(environment_node.environment, "volumetric_fog_density", fog_density, 5.0)

func _get_target_energy(integrity: float) -> float:
	var percent = integrity / 100.0
	# Base energy should not drop to 0 completely unless blackout
	return lerp(0.3, initial_energy, percent)
