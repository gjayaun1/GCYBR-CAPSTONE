# GCYBER: Capstone Project

Lightweight Godot prototype for teaching basic cybersecurity concepts through three quick minigames
- **Phishing** – classify emails as Phish/Legit
- **Password** – build a strong password (length + digit + symbol)
- **Ransomware** – react quickly (Patch or Backup) under a timer

The app uses a simple **Main Menu → Hub → Minigames** flow and a global `Game` autoload to track state, achievements, and persistence across sessions.

---

## How to Run

### Requirements
- Godot **4.5.x** (Forward+ renderer is fine)
- Windows / macOS / Linux

### Open & Play
1. Open Godot → **Import** → select this project’s folder (the one containing `project.godot`).
2. Set **Main Scene** to `res://scenes/MainMenu.tscn`  
   *(Project → Project Settings → Application → Run)*.
3. **F5** to run the full game (or **F6** to run a single scene).

### Controls
- **Mouse**: click UI buttons
- **Keyboard (Ransomware)**: press **P** (Patch) or **B** (Backup) when prompted

**Autoload:**  
Project → Project Settings → **Autoload** → add `res://scripts/Game.gd` with the name **`Game`** (Singleton checked).

---

## How to Use / Teacher Notes

- Launch the app → **Start** → **Hub**
- Pick a minigame:
  - **Phishing:** read the email body and choose **Phish** or **Legit**
  - **Password:** type a password and hit **Check**  
    - Must be **≥ 8 characters**
    - Must contain **a digit**
    - Must contain **a symbol**
  - **Ransomware:** react within the countdown  
    - Press **P** to patch  
    - Press **B** to backup  
- **Back** returns to the previous screen
- The **Hub** shows cumulative progress via the `Game` singleton

---

## Documentation

API documentation generated using **Doxygen**.

- **HTML Documentation:** https://gjayaun1.github.io/GCYBR-CAPSTONE/

---

# Release Notes

## What’s Working in This Submission

### **Core Flow**
**Main Menu → Hub → Phishing / Password / Ransomware → Back to Hub**

### **Popups**
All three minigames include an **intro popup** explaining:
- Goals
- Rules
- How to play

### **Achievements (Autoload + Persistence)**
Three unlockable achievements:
- **`password_master`**
- **`phishing_pro`**
- **`ransomware_hero`**

Achievements **persist using `ConfigFile`** and display on the Hub.

### **Minigames**

#### **Phishing**
- Intro popup
- Multiple prompts
- Correctness feedback
- Achievement unlock

#### **Password**
- Two-phase **strong / weak** system
- Rule-based checking (length / digit / symbol)
- Detailed feedback
- Achievement unlock

#### **Ransomware (Redesigned)**
- Multi-step ransomware-response simulation  
  - Press **D → B → S** before the timer expires
- Intro popup
- Achievement unlock

### **Global Systems**
- `Game.gd` autoload manages:
  - Achievement tracking
  - Persistence
  - Score (legacy)
  - Last-result state
- Hub displays achievement progress

### **Null-Safety**
- All scenes/scripts verify required nodes at runtime
- Automatically dumps the scene tree if something is misnamed

### **Debug Tools**
- Each scene prints status to Output
- On-screen debug label for fast diagnostics

---

## Known Issues

- Score system is **legacy** and mostly unused after switching to achievements
- UI/UX remains minimal (no custom theme, animations, or SFX)
- Ransomware module has limited visual feedback
- Limited phishing/password content sets (seed-only)

---
