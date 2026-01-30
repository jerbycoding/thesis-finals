# 🎨 VERIFY.EXE — UI/UX REDESIGN SPECIFICATION
## "Enterprise-Clean" / Corporate Minimalist Aesthetic

**Goal:** Transition the game from a "Cyberpunk/Neon" aesthetic to a clean, high-contrast, professional documentation style based on modern enterprise software (Intranets, Security Portals, Technical Documentation).

---

### 1. Visual Foundation (The Palette)

| Element | Hex Code | Usage |
| :--- | :--- | :--- |
| **Page Background** | `#FDFDFD` | Main desktop and app backgrounds. |
| **Header Accent** | `#000000` | Title bars, primary buttons, and heavy headers. |
| **Subtle Grid** | `#EEEEEE` | Desktop wallpaper and layout alignment. |
| **Primary Text** | `#1A1A1A` | Main body text and labels. |
| **Secondary Text** | `#666666` | Metadata, timestamps, and captions. |
| **Success (Flat)** | `#2E7D32` | Compliant states, safe files (No Glow). |
| **Error (Flat)** | `#C62828` | Breaches, malicious files (No Glow). |
| **Warning (Flat)** | `#F57C00` | Efficient states, suspicious alerts. |

---

### 2. Typography & Geometry
*   **Font:** Geometric Sans-Serif (Clean, high readability). Monospace restricted strictly to Terminal and Code blocks.
*   **Corners:** Sharp (0px) to minimal (4px) corner radius. No heavy rounding.
*   **Borders:** 1px or 2px solid lines. No drop shadows except for modal overlays (`#000000` with 20% alpha).
*   **Icons:** Minimalist thin-line monochrome icons.

---

### 3. Brainstorming: Tool-Specific Overhaul

#### Desktop Shell (SOC OS style)
*   **Inspiration:** Linux Desktop (Debian/XFCE).
*   **Top System Bar:** 
	*   Left: "Applications" menu trigger.
	*   Right: Connectivity status, Analyst Username, and Clock.
*   **Bottom Dock:** Centered tray containing shortcuts for core incident response tools (SIEM, Terminal, Email, Tickets).
*   **Icon Alignment:** Secondary utilities (Handbook, Network Map) aligned vertically on the left edge.
*   **Visuals:** Semi-transparent glass effects for bars; flat, high-density icons.

#### A. SIEM Log Viewer (Dashboard style)
*   **Theme:** Enterprise Dark (`#0E1117`).
*   **Layout:** 
	*   **Left Sidebar:** Data management and metadata filters.
	*   **Top Visualization:** Line graph showing temporal log volume.
	*   **Log Stream:** High-density table.
*   **Key Features:**
	*   **Status Indicators:** Discrete colored dots (Red = Error, Blue = Info) at the start of the line.
	*   **Text Highlighting:** Use a `RichTextLabel` to highlight search terms with a background color.
	*   **Zebra Stripping:** Subtle background difference between rows for readability.

#### B. Terminal (Forensic TUI style)
*   **Inspiration:** `binsider` / Retro-Modern Terminal.
*   **Layout:** Structured "Box" design using ASCII-style borders.
	*   **Header:** Mode tabs (LOGS | TRACE | ISOLATE).
	*   **Main:** Center data blocks for Host Metadata and Results.
	*   **Footer:** Hotkey legend (e.g., `[TAB: Next Mode] [ENTER: Confirm Action]`).
*   **Aesthetic:** High-contrast White-on-Black or Teal-on-DarkGrey. No neon glows.

#### C. Email Analyzer (Corporate SaaS style)
*   **Inspiration:** Modern SaaS (Gmail/Slack/Notion).
*   **Layout:** Three-column view.
	*   **Left (Nav):** Folders and Status Filters.
	*   **Middle (List):** Email preview cards with discrete colored "Risk Bars."
	*   **Right (Content):** Full document view with attachment "Tile" indicators.
*   **Aesthetic:** Light-mode base (`#FDFDFD`) with vibrant accent colors for primary buttons (e.g., "QUARANTINE" in Solid Red).

#### D. Ticket Queue (Task list style)
*   **Current:** Glowing cards with progress bars.
*   **New:** Clean white cards with a black left-border indicator. Use bold black headers for ticket IDs.

#### D. The 3D World (The Office)
*   **Current:** Dark blue lighting with neon screens.
*   **New:** "Daylight" office environment. Neutral greys and whites. The screens in the office use the same light-mode UI as the player's desktop.

---

### 4. Implementation Checklist
- [ ] Create `Theme` resource with `StyleBoxFlat` overrides for the new palette.
- [ ] Refactor `App_TicketQueue.tscn` to use the high-contrast card layout.
- [ ] Refactor `App_SIEMViewer.tscn` into a document-style table.
- [ ] Update `NotificationToast.gd` to remove neon glows and shake effects.
- [ ] Adjust `WorldEnvironment` to a neutral, bright corporate lighting setup.
