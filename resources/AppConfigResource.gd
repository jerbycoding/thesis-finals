# AppConfigResource.gd
extends Resource
class_name AppConfig

@export var app_id: String = ""
@export var scene_path: String = ""
@export var title: String = ""
@export var default_size: Vector2 = Vector2(600, 400)

enum RoleRequirement { ANALYST, HACKER, BOTH }
@export var required_role: RoleRequirement = RoleRequirement.BOTH

@export_group("Restrictions")
@export var is_restricted: bool = false
@export var required_category: String = "" # e.g., "Ransomware"
@export var required_tool_id: String = "" # e.g., "decrypt"
@export var restriction_message: String = "ACCESS DENIED: This application requires specific incident context."


func validate() -> bool:
	if app_id.is_empty(): return false
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path): return false
	if title.is_empty(): return false
	return true
