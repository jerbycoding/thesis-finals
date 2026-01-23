# CalibrationMinigameConfig.gd
extends Resource
class_name CalibrationMinigameConfig

@export_group("Signal Lock Phase")
@export var difficulty_speed: float = 300.0 # Speed of the needle movement
@export var zone_min_size: float = 0.1 # Minimum percentage of bar length for target zone
@export var zone_max_size: float = 0.3 # Maximum percentage of bar length for target zone

@export_group("Handshake Phase")
@export var max_handshake_time: float = 5.0 # Time limit for typing phase
@export var typing_time_penalty: float = 0.5 # Penalty for incorrect character
@export var codes: Array[String] = [
	"INIT_LINK_0x4F", "SYNC_PROTOCOL_A", "SECURE_TUNNEL", 
	"GATEWAY_REBOOT", "NODE_HANDSHAKE", "ENCRYPT_STREAM"
] # Pool of codes for typing minigame

@export_group("Minigame General")
@export var is_critical_probability: float = 0.4 # Chance for a router to be critical and trigger minigame

@export_group("Audit Tasks")
# Array of dictionaries, each defining a task for the MaintenanceHUD
# e.g. [{"id": "audit_1", "description": "Audit Router Node A"}]
@export var tasks: Array[Dictionary] = [
	{"id": "audit_1", "description": "Audit Router Node A"},
	{"id": "audit_2", "description": "Audit Router Node B"},
	{"id": "audit_3", "description": "Audit Router Node C"},
	{"id": "audit_4", "description": "Audit Router Node D"},
	{"id": "audit_5", "description": "Audit Router Node E"},
	{"id": "audit_6", "description": "Audit Router Node F"}
]
