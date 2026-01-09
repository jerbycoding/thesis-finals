# 🧪 Gameplay Test: The First Shift (15-Minute Vertical Slice) - v2

## 🎯 **Objective**
This test plan outlines the procedure for playing through the complete "First Shift" gameplay arc. The goal is to validate the integration of the narrative systems with the core gameplay mechanics and confirm the game's current behavior.

---

## 🕹️ **Test Procedure**

Follow these steps in order. Note the specific outcomes for each path.

1.  **Start the Game:**
    *   Run the project and click **"Start Shift"**.

2.  **The Briefing:**
    *   The game transitions to the `BriefingRoom`.
    *   The CISO dialogue starts automatically.
    *   **Action:** Proceed through the dialogue. The final choice will transition you to the `SOC_Office`.

3.  **Begin the Shift:**
    *   **Action:** Walk to a computer and interact with it to enter the 2D desktop.

4.  **Ticket 1: Phishing Investigation:**
    *   After about 10 seconds, the first ticket will appear in the `TicketQueue` app.
    *   **Action:** Open the `Email Analyzer` tool, find the email from the "CEO" with the subject "Confidential: Q4 Financial Review".
    *   **Action (CRITICAL):** Make a choice to test one of two paths.

---

### **PATH A: The Compliant Path**

*   **Action:** In the Email Analyzer, first click **"Scan Attachments"** (reveals the `.exe` is malicious), then click **"Quarantine"**.
*   **Expected Outcome:**
    1.  The ticket will be completed with a "compliant" status.
    2.  The Senior Analyst will start a dialogue with you in the 3D world.
    3.  After the dialogue, **no new high-priority tickets will spawn immediately.** The game will continue until the main shift timer runs out.

### **PATH B: The Risky Path**

*   **Action:** In the Email Analyzer, click **"Quarantine"** *without* first clicking "Scan Attachments".
*   **Expected Outcome:**
    1.  The ticket will be completed with an "efficient" status.
    2.  You will see **two "follow-up ticket" notifications**. One is for `EFFICIENT-RISK` and the other is for the hidden risk you took, `MALWARE-CLEANUP-NARRATIVE`.
    3.  The Senior Analyst will start a dialogue with you in the 3D world.
    4.  After the dialogue, two new tickets will be added to your queue. You will need to complete these.

---

5.  **End of Shift:**
    *   The end-of-shift report screen is triggered by a timer. It will appear **900 seconds (15 minutes)** after the shift officially starts (after the CISO briefing).
    *   **Note:** If you finish the tickets early, you will have to wait for this timer to expire.

---

## ✅ **Verification Checklist**

As you proceed, verify the following points:

-   [ ] **Briefing & Transition:** The CISO dialogue starts and correctly transitions you to the SOC Office.
-   [ ] **First Ticket:** The "Spear Phishing Investigation" ticket spawns as expected.
-   [ ] **Path A Outcome:** Completing the ticket compliantly results in **no immediate new tickets**.
-   [ ] **Path B Outcome:** Completing the ticket riskily results in **two new follow-up tickets** appearing in the queue.
-   [ ] **Senior Analyst Interaction:** The Senior Analyst dialogue triggers after the first ticket is resolved on both paths.
-   [ ] **Movement After Dialogue:** Player movement is correctly restored after the Senior Analyst dialogue finishes.
-   [ ] **Shift Report Timer:** The shift report screen appears after the 15-minute timer, not before.
-   [ ] **No Critical Bugs:** The game does not crash or enter an unrecoverable state during the test.
