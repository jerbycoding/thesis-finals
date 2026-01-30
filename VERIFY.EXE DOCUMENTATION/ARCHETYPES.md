# 📊 Analyst Archetypes & Operational Outcomes

In **VERIFY.EXE**, the player's performance is analyzed at the end of every shift by the `ArchetypeAnalyzer.gd`. This system derives metrics from the `ConsequenceEngine.gd` choice history to determine the player's "Operational Persona."

## The Evaluation Logic
Archetypes are determined based on three primary metrics:
1.  **Compliance Rate:** Percentage of tickets closed with all required evidence.
2.  **Risk Posture:** Frequency of using "Efficient" or "Emergency" shortcuts.
3.  **Efficiency:** Average time taken to resolve a threat vs. the base time.

---

## 🛡️ By-the-Book (The Compliance Officer)
*   **Criteria:** 100% Compliant closures. 0 risks taken. No ignored tickets.
*   **Narrative Feedback:** Commended for meticulousness. The organization is stable, though occasional complaints about "slow response times" may emerge.
*   **Best For:** Stability-focused players.

## 🤠 Cowboy (The Decisive Responder)
*   **Criteria:** Multiple "Efficient" closures or an average completion time under 60 seconds while taking risks.
*   **Narrative Feedback:** Recognized for incredible speed. However, warned about the long-term "hidden costs" of rushing investigations.
*   **Social Impact:** IT Support usually hates the Cowboy because of frequent, often unjustified host isolations.

## ⚖️ Pragmatic (The Balanced Analyst)
*   **Criteria:** The default path. A mix of Compliant and Efficient closures depending on the severity.
*   **Narrative Feedback:** Noted for good judgment. Knows when to follow the rules and when to prioritize speed during a crisis.
*   **Narrative Outcome:** The ideal outcome for most operational managers.

## ⚠️ Negligent (The Liability)
*   **Criteria:** More tickets ignored (Timed Out) than completed. 
*   **Narrative Feedback:** Immediate review required. You are a liability to the SOC.
*   **Outcome:** Consistently being categorized as Negligent is the primary trigger for the **"FIRED"** ending.

---

## 🔮 Multi-Week Reset (The Career Reset)
If a player reaches a terminal state of low Integrity or a "Hated" relationship with the CISO, they may be offered the **Redemption Path** (Black Ticket). Successful completion purges the "Negligent" metric and allows the player to continue their career with a clean record.
