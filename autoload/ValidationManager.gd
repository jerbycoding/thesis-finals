# ValidationManager.gd
# Central authority for gameplay rules and logic validation.
extends Node

# === SOLO DEV PHASE 2: ROLE GUARD ===
# ROLE GUARD: This manager's rules apply only to the Analyst campaign.
# Hacker commands bypass validation entirely. Do not add hacker-specific
# validation logic here - that belongs in Phase 3+ systems.
# ================================

# --- Ticket Validation ---

## Checks if a ticket meets the requirements for a "Compliant" resolution.
func can_complete_compliant(ticket: TicketResource) -> bool:
	if not ticket:
		return false
	return ticket.has_sufficient_evidence()

## Checks if a specific resolution type is allowed for a ticket.
func is_resolution_allowed(ticket: TicketResource, type: String) -> bool:
	if not ticket: return false
	
	# During Tutorial / Guided Mode, restrict resolution types based on current step
	if GameState and GameState.is_guided_mode and TutorialManager:
		if ticket.ticket_id.begins_with("TRN-"):
			# Step 28 (Index 27) specifically teaches the 'Efficient' shortcut
			if TutorialManager.current_step == 28:
				return type == GlobalConstants.COMPLETION_TYPE.EFFICIENT
			
			# All other training tickets MUST be compliant
			# Explicitly block 'efficient' and 'emergency'
			if type == GlobalConstants.COMPLETION_TYPE.EFFICIENT or type == GlobalConstants.COMPLETION_TYPE.EMERGENCY:
				return false
				
			return type == GlobalConstants.COMPLETION_TYPE.COMPLIANT
			
	return true

# --- Email Validation ---

## Checks if the player has performed enough investigation to act on an email.
func can_action_email(inspection_state: Dictionary) -> bool:
	# Requires at least one inspection tool to have been used
	for tool_used in inspection_state.values():
		if tool_used == true:
			return true
	return false

# --- Terminal Validation ---

## Checks if a host is authorized for isolation (must be scanned first).
func can_isolate_host(hostname: String) -> bool:
	# During tutorial, allow failure (don't block the button/command)
	if GameState and GameState.is_guided_mode:
		return true
		
	if not NetworkState:
		return false
	var host_info = NetworkState.get_host_state(hostname)
	return host_info.get("scanned", false)

# --- Resource Validation (Pass-through) ---

func validate_resource(resource: Resource) -> bool:
	if resource.has_method("validate"):
		return resource.validate()
	return true
