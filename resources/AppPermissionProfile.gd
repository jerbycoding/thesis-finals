# AppPermissionProfile.gd
extends Resource
class_name AppPermissionProfile

@export var profile_name: String = "Default"
## List of app IDs that are allowed under this profile.
@export var allowed_apps: Array[String] = ["tickets", "siem", "email", "terminal", "handbook", "network", "taskmanager", "decrypt"]
## Message shown when an app outside the whitelist is opened.
@export var restricted_message: String = "ACCESS DENIED: Required security clearance level not detected."

func is_allowed(app_name: String) -> bool:
	return app_name in allowed_apps
