# EventBus.gd
# Central hub for all global signals to decouple systems.
extends Node

# --- Ticket Signals ---
signal ticket_added(ticket: TicketResource)
signal ticket_selected(ticket: TicketResource)
signal ticket_completed(ticket: TicketResource, completion_type: String, time_taken: float)
signal ticket_ignored(ticket: TicketResource)
signal ticket_timeout(ticket_id: String)
signal ticket_state_updated(ticket: TicketResource)
signal log_attached_to_ticket(ticket_id: String, log_id: String)
signal log_detached_from_ticket(ticket_id: String, log_id: String)
signal followup_ticket_creation_requested(ticket: TicketResource)

# --- Log/Forensic Signals ---
signal log_added(log: LogResource)
signal log_reviewed(log_id: String)
signal log_read(log: LogResource)
signal logs_cleared()

# --- Email Signals ---
signal email_added(email: EmailResource)
signal email_read(email: EmailResource)
signal emails_cleared()
signal email_inspected(email: EmailResource, type: String) # type: "headers", "attachments", "links"
signal email_decision_processed(email: EmailResource, decision: String, inspection_state: Dictionary)

# --- Terminal Signals ---
signal terminal_command_run(command_name: String, args: Array)
signal terminal_command_executed(command_name: String, success: bool, output: String)
signal terminal_locked(seconds: float)
signal terminal_unlocked()
signal critical_host_isolated(hostname: String)

# --- Narrative & Shift Signals ---
signal shift_started(shift_id: String)
signal shift_ended(results: Dictionary)
signal shift_end_requested()
signal narrative_spawn_ticket(ticket_id: String)
signal narrative_spawn_consequence(consequence_id: String)
signal consequence_triggered(type: String, details: Dictionary)
signal followup_ticket_scheduled(ticket_id: String, delay: float)
signal npc_interaction_requested(npc_id: String, dialogue_id: String)
signal npc_ready(npc_id: String)
signal dialogue_choice_selected(choice: Dictionary)
signal world_event_triggered(event_id: String, active: bool, duration: float)
signal campaign_ended(type: String)

# --- System & UI Signals ---
signal game_mode_changed(mode: int)
signal app_opened(app_name: String, window_id: String)
signal app_closed(app_name: String, window_id: String)
signal window_focused(window: Control)
signal window_closed(window: Control)
signal host_status_changed(hostname: String, new_status: int)
signal host_state_changed(hostname: String, new_state: Dictionary)
signal host_selected(host: HostResource)
signal audit_node_selected(node_id: String)
signal request_prompt(text: String, active: bool)
signal game_loaded()
signal timer_finished(timer_id: String)
signal permissions_updated()

# --- Transition Signals ---
signal transition_started()
signal transition_obscured()
signal transition_completed()
signal prepare_for_scene_change()

# --- Tool Specific Signals ---
signal decryption_completed(ticket_id: String)
