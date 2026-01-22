# 🎮 Phase 4: Content Expansion Priorities

**Goal:** To significantly increase gameplay variety and replayability by expanding existing content types, without introducing new core systems. This phase leverages the data-driven architecture established in Phase 3.

---

## Guiding Principle: Variety, Not Depth

In Phase 4, the focus is on multiplying existing scenarios and challenges using the tools and systems already in place. If a content idea requires coding a new fundamental system, it should be re-evaluated to see if an existing system can be "reskinned" or adapted.

---

## Key Content Types for Expansion:

Expanding these areas will directly contribute to the "3-5 hours of unique gameplay" exit criteria for Phase 4.

### 1. Shifts (`ShiftResource`)
*   **Importance:** Each shift defines a new day's narrative, objectives, and overall tone. Expanding shifts directly extends the campaign length and progression.
*   **Expansion:** Create new `ShiftResource.tres` files. Define their `shift_id`, `briefing_dialogue_id`, `event_sequence` (timing of ticket spawns, NPC interactions, system events), and `random_event_pool` to introduce procedural variation. Link them via `next_shift_id` for campaign flow.

### 2. Tickets (`TicketResource`)
*   **Importance:** Tickets are the core gameplay loop. New tickets introduce unique security incidents, problems to solve, and decision points.
*   **Expansion:** Create new `TicketResource.tres` files. Vary their `ticket_id`, `title`, `description`, `severity`, `category`, `steps`, `required_tool`, `base_time`, and crucial `required_log_ids`.
*   **Kill Chain Threats:** New tickets can be designed to escalate into multi-stage kill chains by linking `escalation_ticket` resources and defining `kill_chain_path`/`kill_chain_stage`. This adds strategic depth to incident response.

### 3. Logs (`LogResource`)
*   **Importance:** Logs provide the forensic evidence and narrative details within the SIEM tool. More logs mean richer investigations and more convincing simulated environments.
*   **Expansion:** Create new `LogResource.tres` files. Add variety in `source`, `category`, `message`, `severity`, and `ip_address`/`hostname` mentions. Ensure they can be linked to new `TicketResource` files via `related_ticket` and `required_log_ids`.

### 4. Hosts (`HostResource`)
*   **Importance:** Hosts define the network environment, providing targets for terminal commands and context for logs. Expanding hosts increases the scale and complexity of the simulated network.
*   **Expansion:** Create new `HostResource.tres` files. Vary `hostname`, `ip_address`, `is_critical` status, and `os_type`.

### 5. Events (Narrative & System Events)
*   **Importance:** Events dynamically change the game state, introduce sudden challenges, or trigger narrative beats.
*   **Expansion:** Add new event types (identified by `event_id` strings) to `GlobalConstants.gd` if truly necessary, but primarily expand the usage of existing types within `ShiftResource.event_sequence` and `random_event_pool`. These can be `system_event` (e.g., `ZERO_DAY`, `DDOS_ATTACK`), `spawn_ticket`, `spawn_consequence`, or `npc_interaction`.

### 6. Emails (`EmailResource`)
*   **Importance:** Emails provide a primary interface for phishing attempts, user complaints, and internal communications, feeding into the `Email Analyzer` tool.
*   **Expansion:** Create new `EmailResource.tres` files. Diversify `sender`, `subject`, `body`, `attachments`, `headers` (especially spoofing indicators), `is_malicious`, `is_urgent`, `clues`, `related_ticket`, `suspicious_ip`, and `suspicious_domain`.

### 7. NPCs & Dialogues (`DialogueDataResource`)
*   **Importance:** NPCs provide narrative, guidance, and social consequences. Expanding their dialogue enhances the story, character interactions, and player feedback.
*   **Expansion:**
    *   **New Dialogue Chains:** Create new `DialogueDataResource.tres` files for existing NPCs. These can cover new topics, offer different choices, or provide contextual information linked to new tickets or events.
    *   **Contextual Triggers:** Integrate these dialogues into `ShiftResource.event_sequence` as `npc_interaction` events.
    *   **Relationship Impacts:** Design dialogues with `effect` dictionaries that alter `ConsequenceEngine.npc_relationships` to reflect player choices.

### 8. Minigame Content Variations
*   **Importance:** Existing minigames (e.g., `App_Decryption`, `CalibrationMinigame`) can offer more varied challenges.
*   **Expansion:** Add new data for minigames (e.g., more complex "hex codes" for decryption, different calibration patterns, new problem sets for diagnostic tools). This increases challenge without needing to build new minigame systems.

### 9. UI Text & Handbook Entries
*   **Importance:** Consistent and expanded in-game text adds polish, clarity, and depth to the world.
*   **Expansion:** Add new entries to `CorporateVoice.gd` for general system messages, notifications, or specific narrative prompts. Expand the `DOCS` dictionary in `App_Handbook.gd` with new guides on threat types or advanced procedures.

### 10. 3D Environment & Props
*   **Importance:** Reduces visual repetition in the office and adds environmental storytelling.
*   **Expansion:** Create new `.tscn` prop files (stacks of paper, different mugs, tech gadgets) and add them to the `clutter_scenes` array in `PropSpawner` nodes within the main scenes.

### 11. Audio Assets
*   **Importance:** Audio variety prevents fatigue during long play sessions and reinforces event weight.
*   **Expansion:** Import new `.ogg` files. Register them in `AudioManager.gd` or `CorporateVoice.gd` to be triggered by specific events (e.g., a specific "High Stress" track for Day 5 or unique alarms for Critical tickets).

### 12. Analyst Archetypes
*   **Importance:** Provides more varied "endings" and replay goals for players based on their operational style.
*   **Expansion:** Add new definitions to `ARCHETYPE_DEFINITIONS` in `ArchetypeAnalyzer.gd`. Define unique conditions (e.g., "The Specialist" for 100% resolution of a specific category) to reward specific playstyles.

---

By focusing on these content types, the project can achieve significant gameplay variety and narrative richness for Phase 4 while remaining within the bounds of its established and validated core systems.
