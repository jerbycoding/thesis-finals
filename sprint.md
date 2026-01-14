# Sprint: Threat Engineering & Kill Chain System Implementation

## 1. Overview
This sprint focuses on implementing the core "Kill Chain" system, transforming isolated tickets into interconnected attack stages. The development is broken down into three focused weeks.

## 2. Weekly Roadmap

### [Sprint 1: Threat Engineering & Kill Chain](sprint/week1_core_kill_chain.md) (COMPLETED)
*   Foundational Kill Chain logic.
*   Consequence Engine probability.
*   Dynamic Events & Redemption.

### [Sprint 2: Architecture & Tooling Refinement](sprint/week4_resource_automation.md) (IN PROGRESS)
*   [Week 4: Automated Resource Discovery](sprint/week4_resource_automation.md) (COMPLETED)
*   [Week 5: Narrative Decoupling & Shift Resources](sprint/week5_narrative_architecture.md) (COMPLETED)
*   [Week 6: UI Performance & Text Data](sprint/week6_ui_optimization.md) (COMPLETED)

## 3. Definition of Done
*   [ ] Kill Chain paths successfully escalate based on player resolution choices.
*   [ ] `ConsequenceEngine` correctly schedules future tickets.
*   [ ] Dynamic Shift Events affect gameplay as described (timers, UI effects).
*   [ ] Black Ticket redemption path is functional.
*   [ ] Visual feedback (Glow, Tags) correctly notifies player of missed evidence.
