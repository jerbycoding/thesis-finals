# Ransomware Redesign: Crypto-Locker

## Objective
To redesign the `App_Ransomware` from a basic execution window into a high-stakes, industrial "Dead Switch" dashboard. This reinforces the Hacker role's rogue aesthetic and makes the "Immediate Response" anti-abuse mechanic (where Trace jumps to 90%) feel like a massive, point-of-no-return event.

## Key Files & Context
*   **Target Scene:** `res://scenes/2d/apps/App_Ransomware.tscn`
*   **Target Script:** `res://scripts/2d/apps/App_Ransomware.gd`
*   **Dependencies:** Requires `HackerTheme.tres` for styling. Employs the existing `RansomCalibration` minigame component.

## Proposed Solution (The Aesthetic Shift)

The new interface will focus on danger, finality, and cryptographic terminology:
1.  **Header:** Rename to "CRYPTO_LOCKER: FINAL_PAYLOAD".
2.  **Target Overview (The Crosshairs):** A prominent, high-contrast block displaying the current foothold and a simulated "Encryption Key Strength" (e.g., `AES-4096 / RSA-8192`).
3.  **Warning Block:** A flashing or highly visible warning label stating: `[!] ALERT: DEPLOYMENT WILL TRIGGER MAXIMUM SIEM RESPONSE. TRACE FOOTPRINT WILL SPIKE.`
4.  **The "Dead Switch" (Deployment):** A massive, central button labeled "INITIALIZE_ENCRYPTION_SEQUENCE".
5.  **Reactive Payload UI:** Upon successful minigame completion, the app should go into a "LOCKDOWN_MODE" state: the background turns deep red, the button text turns to "PAYLOAD_ACTIVE", and a simulated file-encryption counter rapidly scrolls up.

## Implementation Steps

### Phase 1: Scene Reconstruction (`App_Ransomware.tscn`)
1.  **Layout Refactor:** Use a `VBoxContainer` with distinct sections for Warning, Target Data, Minigame Area, and Deployment Control.
2.  **Visual Polish:** Use `ColorRect` backgrounds behind text elements with stark red/amber accents to create an aggressive, threatening feel.
3.  **Styling:** Apply the high-contrast `HackerTheme` to the root control.

### Phase 2: Script Enhancements (`App_Ransomware.gd`)
1.  **State Management:** Enhance the visual feedback when `_on_deploy_pressed()` is called. Disable other buttons and dim non-essential UI.
2.  **The "Kill Screen" (`_on_minigame_success`):** 
    *   Change the app's background color dynamically to a pulsing dark red.
    *   Initiate a high-speed "Files Encrypted: 0 -> 48,209" counter animation.
    *   Only close the app *after* this dramatic sequence finishes (e.g., 3 seconds).
3.  **Trace UI Integration:** When the jump to 90% Trace occurs, we want the player's attention drawn to the HUD, so a loud "Klaxon" sound effect or a visual screen shake (if available) would be ideal.

## Verification & Testing
1.  Establish a foothold on a target host (e.g., `WORKSTATION-05`).
2.  Launch the "Crypto-Locker".
3.  Verify the aggressive visual styling and the presence of the 90% Trace warning.
4.  Click "INITIALIZE_ENCRYPTION_SEQUENCE".
5.  Complete the calibration minigame.
6.  Verify the "Kill Screen" triggers (red background, file encryption counter).
7.  Verify the HUD Trace Bar immediately jumps to >90% and turns red.
8.  Verify the host status is updated to `RANSOMED`.