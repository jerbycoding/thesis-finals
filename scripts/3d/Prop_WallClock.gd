extends Node3D

@onready var hour_hand = find_child("*Hour*", true, false)
@onready var minute_hand = find_child("*Minute*", true, false)
@onready var second_hand = find_child("*Second*", true, false)

func _process(_delta):
	var time = Time.get_time_dict_from_system()
	
	if hour_hand:
		hour_hand.rotation.z = -deg_to_rad((time.hour % 12) * 30 + (time.minute * 0.5))
	if minute_hand:
		minute_hand.rotation.z = -deg_to_rad(time.minute * 6)
	if second_hand:
		second_hand.rotation.z = -deg_to_rad(time.second * 6)
