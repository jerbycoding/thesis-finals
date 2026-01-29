# ValidationManager.gd
# Central authority for gameplay rules and logic validation.
extends Node

# --- Ticket Validation ---

## Checks if a ticket meets the requirements for a "Compliant" resolution.
func can_complete_compliant(ticket: TicketResource) -> bool:
	if not ticket:
		return false
	return ticket.has_sufficient_evidence()

## Checks if a specific resolution type is allowed for a ticket.
func is_resolution_allowed(ticket: TicketResource, type: String) -> bool:
	if not ticket: return false
	
	# During Tutorial / Guided Mode, force 'compliant' only for training tickets
	if GameState and GameState.is_guided_mode:
		if ticket.ticket_id.begins_with("TRN-"):
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
