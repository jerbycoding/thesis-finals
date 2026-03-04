# Incident Engineering: Cross-Tool Evidence & Forensics

This document explains the "under-the-hood" engineering that ensures every incident in **VERIFY.EXE** has a logical, discoverable forensic trail. Use this to design complex multi-tool investigations.

---

## 1. The SIEM Pipeline (Passive Evidence)

The SIEM does not show all logs at once. It uses a **Dynamic Revelation** system managed by `LogSystem.gd`.

### **How Logs Appear**
When a ticket is spawned, the `LogSystem` performs a sweep of the `res://resources/logs/` library. It reveals any `LogResource` where:
*   **`related_ticket` == `Active Ticket ID`** (Direct match).
*   **`related_ticket` == `"GENERIC"`** (Always visible noise).
*   **`related_ticket` == `""`** (Initial corporate noise).

### **Engineering Strategy**
To ensure a player can always find the "Smoking Gun," you must create at least two logs for every high-severity ticket:
1.  **The Anchor Log**: Contains the `{attacker_ip}` or `{malicious_url}`.
2.  **The Context Log**: Explains the *source* of the alert (e.g., "IDS flagged suspicious beacon").

---

## 2. Terminal Forensics (Active Defense)

The Terminal generates real-time data based on the **Ticket's Truth Packet**.

### **The Netstat Hook (`netstat [hostname]`)**
*   **Logic**: The `TerminalSystem` maintains an `active_connections` map.
*   **Engineering**: When a ticket is active, the `VariableRegistry` injects the `{attacker_ip}` into the connections for the `{victim_host}`.
*   **Result**: The player sees a red **ESTABLISHED** connection to the attacker's IP.

### **The Trace Hook (`trace [ip_address]`)**
*   **Logic**: If the player traces the `{attacker_ip}`, the system checks `trace_overrides`.
*   **Engineering**: By default, an external IP resolves to `[EXTERNAL]`. You can override this in the ticket to resolve to a specific name (e.g., `"Known C2 Server"`) to provide more narrative flavor.

---

## 3. Email Diagnostic Engineering

The Email Analyzer is a specialized forensic tool that parses `EmailResource` fields.

### **Automated Flagging**
Developers don't need to write code for the scanner; the tool uses these rules:
*   **Attachments**: Any filename ending in `.exe`, `.bat`, `.scr`, `.vbs`, or `.js` is automatically flagged as **CRITICAL: Executable Payload**.
*   **Headers**: If `headers["status"]["spf"]` is `"FAIL"`, the tool flags **AUTHENTICATION FAILURE**.
*   **Links**: If `suspicious_domain` matches the ticket's `{malicious_url}`, it is flagged as **BLACKLISTED**.

---

## 4. The "Investigation Loop" Checklist

When engineering a new technical incident, verify this loop:

1.  **Lure**: Player reads an email containing `{malicious_url}`.
2.  **Discovery**: Player searches SIEM for `{malicious_url}` and finds an "Inbound Connection" log from `{attacker_ip}`.
3.  **Verification**: Player runs `netstat {victim_host}` in the Terminal and sees `{attacker_ip}` listed as an active beacon.
4.  **Action**: Player runs `isolate {victim_host}` to stop the beacon.
5.  **Proof**: Player attaches the SIEM log to the ticket and enters `{attacker_ip}` as the Root Cause.

---

## 5. Performance & The Ring Buffer
The `LogSystem` enforces a **150-log limit**. 
*   **Priority Preservation**: When the buffer is full, the system deletes `NOISE-` logs first. 
*   **Critical Logs**: Logs linked to an active ticket ID are **immune** to pruning to ensure the player never loses their evidence mid-investigation.
