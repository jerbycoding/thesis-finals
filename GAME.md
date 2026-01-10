# GAME.md: Codebase Assessment & Maintainability Proposal

## 1. Introduction and Purpose

This document provides an assessment of the current "Incident Response: SOC Simulator" codebase, highlighting areas of technical debt and proposing a strategic plan for refactoring and improvement. The goal is to enhance maintainability, facilitate easier updates, accelerate new feature development, and reduce the risk of introducing bugs.

## 2. Current State of the Codebase (Technical Debt & Key Issues)

While the project demonstrates clear structure and follows some conventions, several areas present technical debt that could impede future development and maintenance.

### 2.1 Tight Coupling Among Autoload Singletons
*   **Observation:** Many Autoload singletons (e.g., `ArchetypeAnalyzer`, `EmailSystem`, `ConsequenceEngine`, `TicketManager`, `NarrativeDirector`, `TerminalSystem`) directly call methods and access properties of other Autoloads.
*   **Impact:**
    *   **Fragility:** Changes to the internal API of one singleton can break functionality in many other parts of the system.
    *   **Complexity:** It's harder to understand the full dependency graph and isolate issues.
    *   **Testing Difficulty:** Unit testing individual singletons becomes challenging due to their strong dependencies.

### 2.2 Hardcoded Dialogue Data within NPC Scripts
*   **Observation:** Dialogue content (lines, choices, effects) for NPCs (`NPC_CISO.gd`, `NPC_ITSupport.gd`, `NPC_SeniorAnalyst.gd`) is defined as dictionaries directly within their GDScript files.
*   **Impact:**
    *   **Maintenance Burden:** Any change to dialogue text, sequence, or effects requires a code change and often a recompilation/restart, increasing the risk of code-related bugs.
    *   **Content Creation Barrier:** Non-programmers cannot easily modify dialogue.
    *   **Code Bloat:** Mixes content data directly with gameplay logic, making scripts longer and less focused.

### 2.3 Fragile Dialogue System Architecture (Static Instance Bug)
*   **Observation:** The `NPC.gd` script uses a `static var dialogue_box_instance` which is managed by the first NPC instance to initiate dialogue.
*   **Impact:**
    *   **Critical Bugs:** Leads to broken signal connections and non-functional dialogue after scene changes, as the original NPC instance (to which the signal was connected) is freed. This directly caused the original "print not showing" issue.
    *   **Inconsistency:** The system becomes unreliable after a major scene transition.

### 2.4 Over-reliance on `_process` for Time-Based Logic
*   **Observation:** Several Autoloads (e.g., `ConsequenceEngine.gd`, `TicketManager.gd`, `TerminalSystem.gd`) utilize the `_process` function (or `create_timer`) for periodic checks or decrementing timers.
*   **Impact:**
    *   **Potential Inefficiency:** While generally okay, if not carefully managed, multiple independent `_process` calls for non-frame-critical time checks can add slight overhead.
    *   **Complexity in Global Time Control:** Pausing or speeding up game time can become more intricate if each system manages its own timers without a central coordinator.

### 2.5 String-Based Identifiers for Critical Lookups
*   **Observation:** Widespread use of string IDs (e.g., `ticket_id`, `email_id`, `log_id`, `npc_id`) for referencing resources and entities across the codebase.
*   **Impact:**
    *   **Typo-Prone:** Typos in string IDs are not caught by the editor and only manifest as runtime errors or unexpected behavior.
    *   **Refactoring Difficulty:** Renaming an ID requires a global text search and replace, increasing the chance of missing an occurrence.

### 2.6 Lack of Formal Automated Testing
*   **Observation:** As noted in `GEMINI.md`, "There is no formal testing framework evident in the project files."
*   **Impact:**
    *   **High Risk Updates:** Every code change carries a significant risk of introducing new bugs or regressions, as there's no automated way to verify existing functionality.
    *   **Slow Development:** Developers must manually test large portions of the game after every change, which is time-consuming and prone to human error.
    *   **Fear of Refactoring:** The lack of a safety net discourages necessary refactoring efforts, leading to further accumulation of technical debt.

## 3. Core Principles for Future Development (Best Practices for Maintainability)

To counter the identified technical debt and foster a healthier codebase, adherence to the following software engineering principles is proposed:

*   **Automated Testing:** Implement a comprehensive suite of tests (unit, integration) to act as a safety net, verifying functionality and enabling confident refactoring.
*   **Refactor in Small, Incremental Steps:** Prioritize continuous, small-scale improvements over large, risky rewrites. Each change should be behavior-preserving and verified by tests.
*   **Single Responsibility Principle (SRP):** Each class, script, or function should have one, well-defined purpose.
*   **Don't Repeat Yourself (DRY):** Avoid code duplication by extracting common logic into reusable functions, classes, or helper scripts.
*   **High Cohesion, Low Coupling:** Group related code together (high cohesion) and minimize direct dependencies between different modules (low coupling) to make components independent and easier to change.
*   **Data-Driven Design:** Separate game data (e.g., dialogue, item stats, enemy properties) from code logic by using Godot's `Resource` system or external data files.
*   **Clear Naming & Consistency:** Use descriptive names for variables, functions, and nodes. Maintain consistent coding styles and project conventions.

## 4. Proposed Refactoring and Improvement Plan

This plan is structured in phases, prioritizing high-impact changes first, followed by broader architectural improvements and ongoing refinements.

### Phase 1: Immediate & High Impact Fixes

These address critical issues and lay the groundwork for more extensive refactoring.

#### 4.1 Refactor Dialogue System to `DialogueManager` Autoload
*   **Problem Addressed:** Fragile Dialogue Architecture (2.3), Hardcoded Dialogue Data (2.2) - partially.
*   **Action:** Implement the `DialogueManager` Autoload singleton (as detailed in `sprint/sprint4bugproposal.md`). This involves:
    *   Creating `autoload/DialogueManager.gd` and registering it.
    *   Moving `DialogueBox` instantiation and management to `DialogueManager`.
    *   Modifying `NPC.gd` to request dialogue from `DialogueManager` and use dynamic signal connections.
    *   Adjusting `DialogueBox.gd` to emit generic choice signals.
    *   Updating `NarrativeDirector.gd` to use the `DialogueManager`.
*   **Expected Outcome:** A robust dialogue system that functions reliably across scene changes, decoupled from individual NPCs.

#### 4.2 Implement Automated Testing with GdUnit4
*   **Problem Addressed:** Lack of Formal Automated Testing (2.6).
*   **Action:**
    *   Integrate the GdUnit4 testing framework into the project.
    *   Begin by writing unit tests for core Autoload singletons (`TicketManager`, `ConsequenceEngine`, `EmailSystem`, `LogSystem`, `NetworkState`, and the new `DialogueManager`). These are foundational and critical systems.
*   **Expected Outcome:** A foundational test suite that provides a safety net for future changes, allowing for confident refactoring and updates.

### Phase 2: Architectural & Data-Driven Improvements

These focus on separating concerns and making content more manageable.

#### 4.3 Formalize Data-Driven Dialogue (DialogueDataResource)
*   **Problem Addressed:** Hardcoded Dialogue Data (2.2).
*   **Action:**
    *   Define a new custom `Resource` type, `DialogueDataResource.gd`, to hold structured dialogue data (lines, choices, effects).
    *   Convert existing hardcoded `dialogue_data` dictionaries within `NPC` scripts into instances of this new `DialogueDataResource`.
    *   Update `NPC.gd` to export and load its dialogue from an assigned `DialogueDataResource`.
*   **Expected Outcome:** Dialogue content fully separated from code, enabling easier content iteration by designers and cleaner NPC scripts.

#### 4.4 Generalize UI Window Management (DesktopWindowManager Autoload)
*   **Problem Addressed:** Potential for `get_node_or_null` over-reliance in UI (2.6 - related to dynamic loading) and general desktop UI complexity.
*   **Action:**
    *   Create a new Autoload singleton, `DesktopWindowManager.gd`.
    *   Extract the core logic for opening, closing, and managing window instances from `scripts/2d/computer_desktop.gd` into `DesktopWindowManager`.
    *   The `ComputerDesktop.gd` will then use `DesktopWindowManager`'s API to launch and interact with windows, effectively becoming a launcher and visual container.
*   **Expected Outcome:** A more modular and extensible desktop UI system, making it easier to add new applications and manage window states consistently.

#### 4.5 Decoupling Autoloads with Event-Driven Communication
*   **Problem Addressed:** Tight Coupling Among Autoload Singletons (2.1).
*   **Action:**
    *   Identify high-traffic direct method calls between Autoloads.
    *   Refactor these interactions to use custom signals instead. For example, instead of `TicketManager` directly calling `ConsequenceEngine.log_ticket_completion`, `TicketManager` would emit a `ticket_completed` signal with relevant data, and `ConsequenceEngine` would connect to that signal.
*   **Expected Outcome:** Reduced direct dependencies between singletons, leading to a more flexible and maintainable architecture.

### Phase 3: Ongoing & Incremental Refinements

These are continuous efforts that should be integrated into daily development.

#### 4.6 Code Style & Consistency
*   **Problem Addressed:** General code readability and maintainability.
*   **Action:** Consistently apply and enforce project-specific GDScript style guidelines (naming conventions, formatting, comment usage).
*   **Expected Outcome:** A more uniform and readable codebase.

#### 4.7 Minimize String-Based Lookups
*   **Problem Addressed:** String-Based Identifiers (2.5).
*   **Action:** Where feasible and beneficial (e.g., for very frequently accessed items), investigate replacing string-based IDs with direct `Resource` references, `UIDs`, or Godot paths.
*   **Expected Outcome:** Reduced risk of runtime errors due to typos in identifiers.

#### 4.8 Review `_process` Usage for Optimization
*   **Problem Addressed:** Over-reliance on `_process` for Time-Based Logic (2.4).
*   **Action:** Audit Autoloads using `_process` for non-frame-dependent time-based logic. Replace or consolidate these with `Timer` nodes or a dedicated time management system where appropriate to improve clarity and potential performance.
*   **Expected Outcome:** Clearer time management logic and minor performance optimizations.

---
This comprehensive plan aims to systematically address the identified technical debt, making the codebase a solid foundation for continued development.