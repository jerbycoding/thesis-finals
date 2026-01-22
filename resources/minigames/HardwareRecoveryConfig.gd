# HardwareRecoveryConfig.gd
extends Resource
class_name HardwareRecoveryConfig

@export_group("Hardware Spawning")
@export var nvme_to_spawn: int = 2
@export var sata_to_spawn: int = 2
@export var decoy_sata_to_spawn: int = 0 # Number of incorrect SATA drives to spawn
@export var decoy_nvme_to_spawn: int = 0 # Number of incorrect NVMe drives to spawn
@export var spawn_random_clutter: bool = true # If other carryable items should spawn

@export_group("Socket Requirements")
# Dictionary mapping socket_id to required hardware_type
# e.g. {"RACK_1": "nvme_drive", "RACK_2": "nvme_drive", "RACK_4": "sata_drive", "RACK_5": "sata_drive"}
@export var socket_requirements: Dictionary = {
	"RACK_1": "nvme_drive",
	"RACK_2": "nvme_drive",
	"RACK_4": "sata_drive",
	"RACK_5": "sata_drive"
}

@export_group("Maintenance Tasks")
# Array of dictionaries, each defining a task for the MaintenanceHUD
# e.g. [{"id": "rep_1", "description": "Rebuild Rack 01 [NVMe]", "completes_on_socket_id": "RACK_1", "completes_on_hardware_type": "nvme_drive"}]
@export var tasks: Array[Dictionary] = [
	{"id": "rep_1", "description": "Rebuild Rack 01 [NVMe]", "completes_on_socket_id": "RACK_1", "completes_on_hardware_type": "nvme_drive"},
	{"id": "rep_2", "description": "Rebuild Rack 02 [NVMe]", "completes_on_socket_id": "RACK_2", "completes_on_hardware_type": "nvme_drive"},
	{"id": "rep_3", "description": "Rebuild Rack 04 [SATA]", "completes_on_socket_id": "RACK_4", "completes_on_hardware_type": "sata_drive"},
	{"id": "rep_4", "description": "Rebuild Rack 05 [SATA]", "completes_on_socket_id": "RACK_5", "completes_on_hardware_type": "sata_drive"}
]
