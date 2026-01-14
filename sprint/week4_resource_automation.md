# Sprint Week 4: Automated Discovery & Constants

## 1. Objective
Eliminate manual path management and centralize "Magic Strings" to prevent silent failures.

## 2. Tasks
### 2.1 Directory Scanning (The "Auto-Loader")
*   **Implement `FileUtil` helper:** Create a utility to scan directories for `.tres` files.
*   **Update `LogSystem.gd`:** Remove `log_library_paths`. Automatically load all files in `resources/logs/`.
*   **Update `EmailSystem.gd`:** Remove `email_library_paths`. Automatically load all files in `resources/emails/`.
*   **Update `TicketManager.gd`:** Automatically populate the library from `resources/tickets/`.

### 2.2 Constant Centralization
*   **Event Bus:** Move event strings (e.g., `ZERO_DAY`, `SIEM_LAG`) into a central `GlobalConstants.gd` singleton.
*   **Severity Enums:** Replace "Critical", "High" strings with formal Enums to avoid typos.

## 3. Technical Requirements
*   `DirAccess` must be used to crawl directories at runtime.
*   Systems must verify that loaded resources are of the correct type (using `is` keyword).
