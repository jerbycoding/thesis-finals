# TASK 5: CONTENT AUTHORING & NARRATIVE (HACKER)

## Description
[NEW] Author all the necessary narrative content, dialogue resources, and shift data for the 7-day hacker campaign.

## Implementation Details

### A. Hacker Shifts
*   **[BLOCKER]** Create and populate all seven `day_{N}.tres` files in `res://resources/hacker_shifts/`.
    *   **Day 1:** Tutorial. One contract, no payload required.
    *   **Day 2:** First exfiltration. One honeypot.
    *   **Day 7:** Final exfiltration, Broker reveal, `hacker_campaign_complete` hook.
*   **[BLOCKER]** Populate `available_hosts`, `honeypot_hosts`, and `scripted_events` for each day.

### B. Broker Dialogue
*   Create all Broker dialogue resources at `res://resources/dialogues/broker/broker_day{N}_{slug}.tres`.
*   Ensure the tone is consistent: clinical, information-dense, and professional.

### C. Contract Population
*   Create and populate `ContractResource` files for all seven days.
*   Verify that `required_payload` and `required_data_type` are correctly set for each.

## Success Criteria
- [ ] **[BLOCKER]** All seven `day_{N}.tres` shift files exist and are correctly populated.
- [ ] **[BLOCKER]** All seven days have Broker intro dialogue resources.
- [ ] **[BLOCKER]** Every Day has at least one valid contract that can be accepted and fulfilled.
- [ ] Contract technical indicators (tokens) resolve correctly within the authored narrative text.
