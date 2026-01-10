# 🧪 **SPRINT 5 - GAMEPLAY ARC PLAYTEST**

## 🎯 **Objective**
This playtest is designed to verify the complete game loop implemented in Sprint 5. This includes:
1.  Playing through the **First Shift**.
2.  Triggering the **auto-save** at the end of the shift.
3.  **Loading the saved game** using the "Continue" button.
4.  Successfully starting and playing the beginning of the **Second Shift**.

---

## ⚙️ **Setup Instructions**

1.  **Delete Previous Save File (Important):** To ensure a clean test, you must delete any existing save file.
    *   The save file is named `savegame.json`.
    *   It is located in Godot's `user://` directory. The exact location depends on your operating system, but it will be in a path like:
        *   **Windows:** `C:\Users\<YourUser>\AppData\Roaming\Godot\app_userdata\ThesisBETA`
        *   **macOS:** `~/Library/Application Support/Godot/app_userdata/ThesisBETA`
        *   **Linux:** `~/.local/share/godot/app_userdata/ThesisBETA`
    *   **Please delete the `savegame.json` file in that folder before starting.**

---

## ⏯️ **Test Steps: Shift 1**

1.  **Launch the Game.**
2.  From the Title Screen, click **"START NEW SHIFT"**.
3.  You should be transported to the **Briefing Room**. Interact with the CISO and complete the initial briefing dialogue.
4.  After the dialogue, you will be in the SOC Office. Interact with the computer to enter the 2D desktop.
5.  A ticket, **"Spear Phishing Investigation" (`SPEAR-PHISH-001`)**, should appear shortly. This is the `phishing_intro` from the narrative.
    *   Open the **Email Analyzer** app.
    *   Find the relevant email ("Confidential: Q4 Financial Review").
    *   Make a decision. For this test, **Quarantine** the email.
6.  After the ticket is completed, the **Senior Analyst** should approach you for a dialogue. Complete this interaction.
7.  Another ticket, **"Malware Containment Request" (`MALWARE-CONTAIN-001`)**, should appear.
    *   Open the **Terminal** app.
    *   Use the `scan WORKSTATION-45` command.
    *   Use the `isolate WORKSTATION-45` command to complete the ticket.
8.  Continue playing until the shift timer runs out and the **Shift Report** screen appears.

---

## ✅ **Verification: End of Shift 1**

*   **Observe:** Did the Shift Report screen appear correctly, showing your archetype and stats?
*   **Check Logs:** The Godot output/log should contain the line: `Game state saved successfully to: <path>`. This confirms the auto-save worked.

---

## 🔄 **Test Steps: Loading & Shift 2**

1.  From the Shift Report screen, click the **"Continue"** button. This should take you back to the main office scene and immediately start the second shift.
    *   *(Alternative Test)*: Quit the game from the shift report. Relaunch the application. The **"CONTINUE"** button should now be visible on the Title Screen. Click it.
2.  You should load into the **SOC Office**.
3.  The **CISO** should initiate a new dialogue for the second shift briefing.
4.  After the dialogue, a new ticket **"Ransomware Alert: Critical Server Locked!" (`RANSOM-001`)** should appear.
5.  Attempt to handle this new ticket using the tools.

---

## 📝 **Feedback & Observations**

Please note down any of the following:
*   **Bugs:** Did the game crash? Did something not happen when it was supposed to? (e.g., a ticket didn't appear, a button didn't work).
*   **Confusion:** Was any part of the process unclear? Did you not know what to do next at any point?
*   **Save/Load Issues:** Did the "Continue" button not appear? Did your state (like completed tickets) seem incorrect after loading?
*   **General Impressions:** Does the loop feel correct?

**[ Please write your findings below this line ]**

---
