# TASK 5: APP REGISTRATION & METADATA (PAYLOADS)

## Description
Create and configure all the necessary metadata files and permissions to register the payload apps for the Hacker campaign.

## Implementation Details
*   **App Configs:**
    *   [x] Create an `AppConfigResource` file for `App_Ransomware.tscn`.
    *   [ ] Create an `AppConfigResource` file for `App_Exfiltrator.tscn`.
    *   [ ] Create an `AppConfigResource` file for `App_Wiper.tscn`.
    *   [x] Create an `AppConfigResource` file for `App_ContractBoard.tscn`.
*   **Hacker Profile Registration:**
    *   [x] Add `App_Ransomware` and `App_ContractBoard` to `resources/permissions/HackerAppProfile.tres`.
    *   [ ] Add `App_Exfiltrator` and `App_Wiper` to `resources/permissions/HackerAppProfile.tres`.
*   **Invisibility Verification:**
    *   [x] Verify that these apps are **not** present in the Analyst's `AppPermissionProfile` files (e.g., `training_permissions.tres`).

## Success Criteria
- [x] `AppConfigResource` files exist for Ransomware and Contracts.
- [ ] `AppConfigResource` files exist for Exfiltrator and Wiper.
- [x] Payload apps appear in the Hacker's app launcher.
- [x] Payload apps are invisible to the Analyst.
