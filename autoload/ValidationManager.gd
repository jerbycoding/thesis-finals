# ValidationManager.gd
# Central authority for gameplay rules and logic validation.
extends Node

# --- Ticket Validation ---

## Checks if a ticket meets the requirements for a "Compliant" resolution.
func can_complete_compliant(ticket: TicketResource) -> bool:
	if not ticket:
		return false
	return ticket.has_sufficient_evidence()

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
	if not NetworkState:
		return false
	var host_info = NetworkState.get_host_state(hostname)
	return host_info.get("scanned", false)

# --- Resource Validation (Pass-through) ---

func validate_resource(resource: Resource) -> bool:
	if resource.has_method("validate"):
		return resource.validate()
	return true
