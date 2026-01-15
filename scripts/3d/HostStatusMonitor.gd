# HostStatusMonitor.gd
# Diegetic display for network isolation status
extends Label3D

func _ready():
	# Update every second instead of every frame for performance
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(_update_display)
	add_child(timer)
	timer.start()
	
	_update_display()

func _update_display():
	if not NetworkState: return
	
	var all_hosts = NetworkState.get_all_hostnames()
	var isolated_count = 0
	
	for host in all_hosts:
		if NetworkState.get_host_state(host).get("isolated", false):
			isolated_count += 1
	
	text = "NETWORK STATUS\n"
	text += "--------------\n"
	text += "ACTIVE HOSTS: %d\n" % all_hosts.size()
	
	if isolated_count > 0:
		text += "ISOLATED: [color=orange]%d[/color]" % isolated_count
		outline_modulate = Color.ORANGE
	else:
		text += "ISOLATED: 0"
		outline_modulate = Color.BLACK
