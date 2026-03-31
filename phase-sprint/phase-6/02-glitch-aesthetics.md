# TASK 2: VISUAL & AUDIO "GLITCH" IDENTITY

## Description
Define the aesthetic difference between "Corporate Blue" (Analyst) and "Underground Green" (Hacker).

## Implementation Details
*   **Shaders:** Apply a subtle "Chromatic Aberration" or "Vignette" shader to the hacker desktop when `TraceLevel` is high.
*   **Audio:** Use `AudioManager` to swap the standard office ambiance for a "Lofi/Underground" loop with electronic interference SFX when playing as the hacker.
*   **UI Reskin:** Utilize `GlobalConstants` (e.g., `COLOR_HACKER_GREEN`, `COLOR_TRACE_CRITICAL`) to swap the UI theme. This should be handled by `DesktopWindowManager.set_theme(role)`.

## Success Criteria
- [ ] Hacker desktop UI has a distinct color theme.
- [ ] Ambient audio loop is different for the hacker role.
- [ ] Visual shader effects respond dynamically to the `TraceLevel`.
