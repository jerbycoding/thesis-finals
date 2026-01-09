extends Label

var update_timer: float = 0.0
var update_interval: float = 1.0  # Update every second

func _ready():
	update_clock()

func update_clock():
	var time = Time.get_time_dict_from_system()
	# Format: HH:MM:SS
	text = "%02d:%02d:%02d" % [time.hour, time.minute, time.second]
	# Or for just HH:MM: text = "%02d:%02d" % [time.hour, time.minute]

func _process(delta):
	update_timer += delta
	if update_timer >= update_interval:
		update_timer = 0.0
		update_clock()
