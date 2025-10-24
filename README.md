#Alpha Capstone Game

Lightweight Godot prototype for teaching basic cybersecurity concepts through three quick minigames
- **Phishing** – classify emails as Phish/Legit
- **Password** – build a strong password (length + digit + symbol)
- **Ransomware** – react quickly (Patch or Backup) under a timer

The app uses a simple **Main Menu → Hub → Minigames** flow and a global `Game` autoload to track score across sessions.

---

## How to Run

### Requirements
- Godot **4.5.x** (Forward+ renderer is fine)
- Windows/macOS/Linux

### Open & Play
1. Open Godot → **Import** → select this project’s folder (the one containing `project.godot`).
2. Set **Main Scene** to `res://scenes/MainMenu.tscn` (Project → Project Settings → Application → Run).
3. **F5** to run the full game (or **F6** to run a single scene).

### Controls
- **Mouse**: click UI buttons
- **Keyboard (Ransomware)**: press **P** (Patch) or **B** (Backup) when prompted


**Autoload:** Project → Project Settings → **Autoload** → add `res://scripts/Game.gd` with the name **`Game`** (Singleton checked).

---

## How to Use / Teacher Notes

- Launch the app → **Start** → **Hub**.
- Pick a minigame:
  - **Phishing:** read the email body and choose **Phish** or **Legit**. Score +1 on correct.
  - **Password:** type a password and hit **Check**. Must be **≥ 8 chars**, contain **a digit**, and **a symbol**.
  - **Ransomware:** react within the countdown; press **P** to patch or **B** to backup (prompt varies). Score +1 on success.
- **Back** returns you to the prior screen; the **Hub** shows your cumulative score via the `Game` singleton.

---

## Release notes

> What’s working in this submission

- **Core flow:** Main Menu → Hub → Phishing / Password / Ransomware → Back to Hub
- **Minigames:**
  - **Phishing:** multiple prompts, correctness feedback, score updates
  - **Password:** rule-based checker (length/digit/symbol), feedback with missing-rule hints
  - **Ransomware:** timed reaction loop (3 rounds), keyboard input (P/B)
- **Global score:** `Game.gd` autoload with `score_changed` signal; Hub label updates live
- **Null-safety:** all scenes/scripts verify required nodes at runtime and show clear on-screen errors if something is misnamed
- **Debug:** each scene prints minimal status to Output and a small on-screen label for quick diagnosis

> Known issues

- No persistence (score resets on app restart)
- Minimal UI/UX (no art theme, accessibility passes, or SFX)
- No difficulty scaling or content authoring tools
- Limited phishing/password content sets (seed data only)
