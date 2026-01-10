extends Node


# Autoload singleton for playing sound effects and managing background music.

@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(sfx_player)
	add_child(music_player)
	print("AudioManager initialized.")

func play_sfx(sfx_path: String, volume_db: float = 0.0):
	if ResourceLoader.exists(sfx_path):
		sfx_player.stream = load(sfx_path)
		sfx_player.volume_db = volume_db
		sfx_player.play()
	else:
		push_warning("AudioManager: Sound effect not found at path: %s" % sfx_path)

func play_music(music_path: String, volume_db: float = 0.0, loop: bool = true):
	if ResourceLoader.exists(music_path):
		var audio_stream = load(music_path)
		
		# In Godot 4, the 'loop' property is on the stream, not the player.
		if audio_stream.has_method("set_loop"): # For some stream types
			audio_stream.set_loop(loop)
		elif "loop" in audio_stream: # For AudioStreamOggVorbis
			audio_stream.loop = loop
			
		music_player.stream = audio_stream
		music_player.volume_db = volume_db
		music_player.play()
	else:
		push_warning("AudioManager: Music not found at path: %s" % music_path)

func stop_music():
	music_player.stop()

# Predefined SFX paths (example)
var SFX = {
	"notification_info": "res://assets/sfx/notification_info.ogg", #/
	"notification_success": "res://assets/sfx/notification_success.ogg", #/
	"notification_warning": "res://assets/sfx/notification_warning.ogg", #/
	"notification_error": "res://assets/sfx/notification_error.ogg", #/
	"button_click": "res://assets/sfx/button_click.ogg", # /
	"terminal_beep": "res://assets/sfx/terminal_beep.ogg",  #/
	"music_ambient_desktop": "res://assets/music/ambient_desktop.ogg", # /
	# Add more as needed
	"consequence_alert": "res://assets/sfx/notification_error.ogg", # Using existing error sound
	"ticket_spawn": "res://assets/sfx/newTicket.ogg", # Using existing new ticket sound
	"ui_hover": "res://assets/sfx/button_click.ogg", # Using existing button click sound
}
