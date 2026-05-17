# 🎮 Hangman Game in 8086 Assembly (EMU8086)

A complete Hangman Game developed in 8086 Assembly Language using the EMU8086 Emulator for the Computer Organization & Assembly Language (COAL) course.

This project demonstrates:

* Assembly programming fundamentals
* DOS interrupts
* Memory management
* Arrays & pointer tables
* Procedures
* Game logic implementation in low-level programming

---

# 📌 Project Evolution

## 🔹 Version 1

### Basic Hangman Prototype

Features:

* Simple hangman gameplay
* Word guessing system
* Basic keyboard input
* Initial ASCII hangman drawing

Issues:

* Input response was slow
* Screen refresh caused delays
* Minimal UI

---

## 🔹 Version 2

### Optimized & Improved UI

Improvements:

* Faster input handling
* Optimized game loop
* Cleaner code structure
* Blue themed UI using BIOS interrupts
* Better screen clearing
* Improved gameplay experience

---

## 🔹 Final Version

### Full Enhanced Hangman Game

Major Features Added:

* ✅ 10 Difficulty Levels
* ✅ Random Word Selection
* ✅ Score System
* ✅ Rank System
* ✅ Hint System
* ✅ Lives Counter
* ✅ Wrong Letter Tracking
* ✅ Replay Option
* ✅ ASCII Hangman Animation
* ✅ Input Validation
* ✅ Multi-level Progression
* ✅ Enhanced UI

---

# 🧠 Game Features

## 🎯 Levels System

The game contains 10 levels with increasing difficulty.

Each level contains:

* 5 predefined words
* Longer and more difficult words as levels increase

---

## 🏆 Rank System

| Score Range | Rank         |
| ----------- | ------------ |
| 0–9         | BRONZE       |
| 10–19       | SILVER       |
| 20–29       | GOLD         |
| 30–39       | PLATINUM     |
| 40–49       | DIAMOND      |
| 50–59       | HEROIC       |
| 60–69       | ELITE HEROIC |
| 70–79       | MASTER       |
| 80–89       | ELITE MASTER |
| 90+         | GRAND MASTER |

---

## 💡 Hint System

* One free hint per level
* Reveals one hidden character
* Does not reduce score

---

## ❤️ Lives System

* Player gets 6 lives per level
* Each wrong guess increases hangman stage

---

# 🛠 Technologies Used

* 8086 Assembly Language
* EMU8086 Emulator
* DOS Interrupts (INT 21H)
* BIOS Video Interrupts (INT 10H)

---

# 📂 Project Structure

Hangman-8086/
│
├── Version1/
│   └── Basic Hangman Game
│
├── Version2/
│   └── Optimized UI & Faster Gameplay
│
├── FinalVersion/
│   └── Complete Enhanced Game
│
└── README.md

---

# ⚙️ Important Assembly Concepts Used

This project demonstrates practical implementation of:

* Registers (AX, BX, CX, DX)
* Stack operations (PUSH, POP)
* Procedures (PROC, RET)
* Arrays & Pointer Tables
* Loops & Conditional Jumps
* Memory Addressing
* String Handling
* ASCII Manipulation
* Interrupt Handling
* Randomization using system timer

---

# 🎮 Controls

| Key | Action       |
| --- | ------------ |
| A–Z | Guess Letter |
| ?   | Use Hint     |
| Y   | Play Again   |
| N   | Exit Game    |

---

# 🖥 How to Run

## Requirements

* EMU8086 Emulator

## Steps

1. Open EMU8086
2. Load the .asm source file
3. Compile the program
4. Run the executable

---

# 📸 Gameplay Preview

LEVEL: 3   SCORE: 20   RANK: GOLD   LIVES LEFT: 5

```
  +---+
  |   |
  O   |
 /|   |
      |
      |
=========
```

_ A _ _ _

Wrong letters: X T P

---

# 📚 Learning Outcomes

Through this project, the following concepts were learned:

* Low-level game development
* DOS interrupt programming
* Efficient memory handling
* User input processing
* Assembly-level optimization
* Procedure-based modular programming
* UI handling in text mode
* Pointer table implementation

---

# 🚀 Future Improvements

Possible future upgrades:

* File-based high score saving
* Multiplayer mode
* Sound effects
* Mouse support
* Larger word database
* Difficulty selection menu
* Colored ASCII animations

---

# 👨‍💻 Author

Developed as a COAL (Computer Organization & Assembly Language) semester project using EMU8086.

---

# ⭐ Final Note

This project started as a simple hangman implementation and evolved into a complete multi-level assembly game with advanced gameplay mechanics and optimized performance. It demonstrates how complex logic and interactive games can be built even in low-level 8086 Assembly Language.
