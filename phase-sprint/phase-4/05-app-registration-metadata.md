# TASK 5: APP REGISTRATION & METADATA (PAYLOADS)

## Description
[NEW] Create and configure all the necessary metadata files and permissions to register the payload apps for the Hacker campaign.

## Implementation Details
*   **App Configs:**
    *   Create an `AppConfigResource` file for `App_Ransomware.tscn`.
    *   Create an `AppConfigResource` file for `App_Exfiltrator.tscn`.
    *   Create an `AppConfigResource` file for `App_Wiper.tscn`.
*   **Hacker Profile Registration:**
    *   Add all three new `AppConfigResource` files to `resources/permissions/HackerAppProfile.tres`.
    *   This makes them accessible in the Hacker's app launcher/start menu.
*   **Invisibility Verification:**
    *   Verify that these apps are **not** present in the Analyst's `AppPermissionProfile` files (e.g., `training_permissions.tres`).

## Success Criteria
- [ ] `AppConfigResource` files exist for Ransomware, Exfiltrator, and Wiper.
- [ ] All three payload apps appear in the Hacker's app launcher.
- [ ] All three payload apps are invisible to the Analyst.
