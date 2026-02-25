#Sprint 11: The Certification Phase (Diegetic Onboarding)


  Section 1: Physical Immersion (The "Deep Focus" Transition)
  Goal: Bridge the 3D/2D gap by simulating human eye focus and physical movement.
   * Camera Dolly: Update TransitionManager.gd to lerp FOV from 80 to 60 during the sit_down animation.
   * Depth of Field (DOF): Add a WorldEnvironment controller that tweens dof_blur_far_enabled to true and adjusts far_distance when seated, blurring the office background.   
   * Audio Handoff: Implement a low-pass filter on 3D office sounds (chatter, hum) when the player focuses on the monitor, replaced by a sharp, clear "Digital Desktop"       
     ambient loop.


  Section 2: Instructional Style (The "SOP Runbook" Sidebar)
  Goal: Replace meta-text with a professional, in-world reference tool.
   * Runbook UI: Create a RunbookSidebar.tscn anchored to the right side of the ComputerDesktop.
   * SOP Formatting: Update TutorialManager.gd to parse instructions into a "Command -> Action" format.
       * Visual: Each step has a checkbox that "Syncs" (flashes green) upon completion.
   * CISO Persona: Integrate the CommsSidebar so the CISO provides the "Why" (Narrative) while the Runbook provides the "What" (Technical).


  Section 3: Visual Language (The "ATG" Guidance System)
  Goal: Upgrade the Focus Mask to look like high-end SOC software.
   * ATG Shader: Enhance focus_mask.gdshader with a scanline texture and a subtle chromatic aberration effect on the dimmed areas.
   * Selection Box: Create a dynamic "Dashed Border" component. When TutorialManager highlights a UI element, a 1-pixel dashed line rotates around the button, signaling a    
     "System Suggestion."
   * Hierarchy of Attention: Implement the 3-Tier highlight system:
       1. Tier 1: Ambient pulse (Standard).
       2. Tier 2: Sharp Flash (Alert).
       3. Tier 3: Full Focus Mask (First-time introduction).


  Section 4: Cognitive Scaffolding (The "Provisioning" Model)
  Goal: Prevent "Dashboard Fatigue" by introducing tools only when the Kill Chain requires them.
   * Dock Provisioning: Modify the application dock icons. Locked apps are displayed in Greyscale with a "Pending SOP Clearance" overlay.
   * The Unlock Sequence: When a TutorialStep requires a new app (e.g., SIEM), play a "Provisioning Access..." progress bar on the icon before it becomes active.
   * Kill Chain Rollout: Restrict the first ticket to only the Queue and Email. Unlock the SIEM only after the first "Source IP" is identified.


  Section 5: Failure Resilience (The "After-Action Review")
  Goal: Turn mistakes into learning moments using a "Sandbox VM" narrative.
   * Sandbox Interception: Update IntegrityManager.gd to check GameState.is_sandbox_mode. If true, integrity hits are diverted to a "Procedural Warning" signal.
   * Remediation Logic: If a player performs a critical error (e.g., isolating a clean host):
       1. Freeze: The Runbook turns Amber.
       2. Alert: CISO Pings with a correction: "Analyst, you just disrupted a benign service. Restore the host immediately."
       3. Halt: The tutorial logic pauses until the "Correction Task" is fulfilled.

  ---