# TutorialStepResource.gd
extends Resource
class_name TutorialStepResource

enum TriggerType { 
	NONE, 
	ZONE_REACHED, 
	APP_OPENED, 
	TICKET_SELECTED, 
	EMAIL_READ, 
	EMAIL_INSPECTED,
	LOG_ATTACHED, 
	COMMAND_RUN, 
	HOST_SELECTED,
	TICKET_COMPLETED
}

@export_group("Narrative")
## The text displayed in the Tutorial HUD.
@export var instruction_text: String = ""
## The sender name for the Comms Sidebar.
@export var comms_sender: String = "CISO"
## The message sent to the Comms Sidebar.
@export_multiline var comms_text: String = ""

enum HighlightTier { 
	NONE, 
	AMBIENT_HINT,   # Subtle icon glow only
	ALERT_FLASH,    # Sharp dashed box flash
	FULL_ATG_FOCUS  # Screen dim + scanlines + box
}

@export_group("Visuals")
## The level of visual guidance for this step.
@export var highlight_tier: HighlightTier = HighlightTier.FULL_ATG_FOCUS
## The node path (relative to Desktop) or Unique Name to highlight.
@export var highlight_path: String = ""
## Whether to make the icon glow (if applicable).
@export var icon_glow_name: String = ""

@export_group("Logic")
## The type of event that advances this step.
@export var trigger_type: TriggerType = TriggerType.NONE
## The specific ID needed to trigger (e.g., 'tickets', 'TRN-001', 'scan').
@export var trigger_id: String = ""
## For log attachments, which ticket ID are we watching?
@export var target_ticket_id: String = ""

func validate() -> bool:
	if instruction_text.is_empty(): return false
	return true
