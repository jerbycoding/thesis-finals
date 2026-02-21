# ConfigManager.gd
# Manages persistent user settings (Volume, Fullscreen, etc.)
extends Node

const CONFIG_PATH = "user://settings.cfg"

var config = ConfigFile.new()

signal setting_changed(section: String, key: String, value: Variant)

# Default settings
var settings = {
	"audio": {
		"master_volume": 0.8,
		"music_volume": 0.7,
		"sfx_volume": 1.0
	},
	"display": {
		"fullscreen": true,
		"borderless": false,
		"crt_enabled": true
	},
	"input": {
		"mouse_sensitivity": 0.002
	},
	"gameplay": {
		"fov": 80.0,
		"difficulty_level": 1, # 0=Junior, 1=Analyst, 2=Lead
		"campaign_completed": false
	}
}

func _ready():
	load_settings()
	apply_settings()

func save_settings():
	for section in settings.keys():
		for key in settings[section].keys():
			config.set_value(section, key, settings[section][key])
	
	var err = config.save(CONFIG_PATH)
	if err != OK:
		push_error("ConfigManager: Failed to save settings to %s" % CONFIG_PATH)
	else:
		print("ConfigManager: Settings saved successfully.")

func load_settings():
	var err = config.load(CONFIG_PATH)
	if err != OK:
		print("ConfigManager: No config file found, using defaults.")
		return

	for section in settings.keys():
		for key in settings[section].keys():
			settings[section][key] = config.get_value(section, key, settings[section][key])
	
	print("ConfigManager: Settings loaded from disk.")

func apply_settings():
	# Apply Audio
	_apply_bus_volume("Master", settings.audio.master_volume)
	# Assuming you have or will have Music/SFX buses
	if AudioServer.get_bus_index("Music") != -1:
		_apply_bus_volume("Music", settings.audio.music_volume)
	if AudioServer.get_bus_index("SFX") != -1:
		_apply_bus_volume("SFX", settings.audio.sfx_volume)

	# Apply Display
	if settings.display.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	print("ConfigManager: Settings applied to engine.")

func _apply_bus_volume(bus_name: String, value: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		# Convert linear 0.0-1.0 to decibels
		var db = linear_to_db(value)
		AudioServer.set_bus_volume_db(bus_index, db)

func set_setting(section: String, key: String, value):
	if settings.has(section) and settings[section].has(key):
		settings[section][key] = value
		save_settings()
		apply_settings()
		setting_changed.emit(section, key, value)
