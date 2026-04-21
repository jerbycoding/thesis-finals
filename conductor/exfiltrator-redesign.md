# Data Exfiltrator Redesign: Tactical Traffic Sniffer

## Objective
To redesign the `App_Exfiltrator` from a standard download manager (which relies on simple progress bars) into a high-density, terminal-themed "Tactical Traffic Sniffer." This reinforces the Hacker role's rogue aesthetic and makes the existing "Bandwidth Alert" anti-abuse mechanic visually explicit and thrilling.

## Key Files & Context
*   **Target Scene:** `res://scenes/2d/apps/App_Exfiltrator.tscn`
*   **Target Script:** `res://scripts/2d/apps/App_Exfiltrator.gd`
*   **Dependencies:** Requires `HackerTheme.tres` for styling. Leverages the existing `bandwidth_timer` logic for visual alerts.

## Proposed Solution (The Aesthetic Shift)

The new interface will focus on data density and live telemetry:
1.  **Header:** Rename to "TACTICAL_TRAFFIC_SNIFFER v2.1".
2.  **Top Panel (Live Metrics):** Display raw technical stats such as `TRANSFER_RATE (KB/s)`, `PACKETS_SNIFFED`, and `ENCRYPTION_PROTOCOL`. These numbers will jitter during active extraction.
3.  **Middle Panel (The Oscilloscope Graph):** Replace the static progress bars with a custom-drawn, scrolling line graph representing real-time bandwidth usage. 
    *   **Visual Alert:** When the `bandwidth_timer` hits 10 seconds and triggers an alert, the graph will instantly spike in amplitude and turn from Terminal Green to Signal Red, visually warning the player of the Trace penalty.
4.  **Bottom Panel (The Intel Feed):** A scrolling terminal window (`RichTextLabel`) that rapidly prints out the names of intercepted files (e.g., `[+] Extracting: /var/log/auth.log... OK`, `[+] Extracting: Q3_Financials_Encrypted.pdf... OK`).

## Implementation Steps

### Phase 1: Scene Reconstruction (`App_Exfiltrator.tscn`)
1.  **Layout Refactor:** Use a `VBoxContainer` partitioned into Metrics (Top), Graph Area (Middle), and Intel Feed (Bottom).
2.  **The Graph Canvas:** Add a dedicated `ColorRect` or `Control` node that will act as the drawing surface for the scrolling graph.
3.  **The Feed:** Add a `RichTextLabel` with `scroll_following = true` for the Intel Feed.
4.  **Styling:** Ensure all panels use the high-contrast `HackerTheme` with pitch-black backgrounds and green/cyan borders.

### Phase 2: Script Enhancements (`App_Exfiltrator.gd`)
1.  **Graph Rendering:** Implement a custom `_draw()` routine or use a `Line2D` node. Store an array of Y-values that shift left every frame based on a target amplitude.
2.  **Amplitude Modulation:** Tie the graph's target amplitude to the total progress speed. When `_trigger_bandwidth_alert()` fires, temporarily set a massive "Alert Amplitude" and change the graph color to red.
3.  **Fake File Generator:** Create an array of generic corporate file names. Every X frames during active extraction, pick a random file and append it to the Intel Feed `RichTextLabel`.
4.  **Metric Jitter:** Update the Metrics panel every frame with slightly randomized numbers based on the host's underlying bandwidth stat.

## Verification & Testing
1.  Establish a foothold on a target host (e.g., `DB-SRV-01`).
2.  Launch the "Tactical Traffic Sniffer".
3.  Click "INITIALIZE_PACKET_CAPTURE".
4.  Verify the graph draws and scrolls correctly.
5.  Verify the Intel Feed prints fake file names.
6.  Wait 10 seconds; verify the graph spikes and turns red when the Bandwidth Alert triggers.
7.  Verify the final payload correctly awards the Intelligence item and Bounty.