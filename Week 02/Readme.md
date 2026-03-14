# 💻 CS50x Week 2 — Scrabble, Readability & Substitution

> 📝 **Blog Post:** [CS50 Week 2 C — Scrabble Scores, Readability Grades and Substitution Ciphers](https://www.parsadev.co.uk/post/cs50-week-2-c-scrabble-scores-readability-grades-and-substitution-ciphers)
> 📚 **CS50x Series:** [All CS50x posts on ParsaDev](https://www.parsadev.co.uk/blog/categories/cs50x)
> 🌐 **Developer:** [parsadev.co.uk](https://www.parsadev.co.uk)

Three problem sets from CS50x Week 2, all written in C. This week is where arrays, strings, and command-line arguments stop being abstract concepts and start being things you actually use to solve real problems — from scoring Scrabble words to encrypting messages with a substitution cipher.

---

## 📌 What It Does

**Scrabble** — Two players each enter a word, and the program scores both using official Scrabble letter point values stored in an integer array. Character arithmetic maps each letter to its index position, handles upper and lower case automatically, and ignores non-alphabetic characters. The higher score wins, with ties declared correctly.

**Readability** — Takes a block of text from the user, counts letters, words, and sentences using separate counting functions, and calculates a US reading grade level using the Coleman-Liau index formula. Words are counted by spaces and the null terminator, sentences by `.`, `!`, and `?` characters, and the result is rounded and printed as a grade.

**Substitution** — Takes a 26-character substitution key as a command-line argument and uses it to encrypt a plaintext message. Each letter of the key maps to the corresponding letter of the alphabet. Three validation functions check the key before any encryption happens, and the ciphering function preserves the original case of the input throughout.

---

## ✨ Features

- Scrabble scorer handles both upper and lower case input with no preprocessing required
- Readability index implemented directly from the Coleman-Liau formula — no libraries
- Substitution key validated across three separate `bool` functions before use:
  - Length check — must be exactly 26 characters
  - Alphabet check — must contain only alphabetic characters
  - Repeat check — no letter may appear more than once
- Ciphering function allocates memory with `malloc` and sets the null terminator manually
- Case preservation — ciphertext matches the capitalisation of the original plaintext
- Command-line argument handling with `argc` and `argv`

---

## 🛠 Tech Stack

| Component | Detail |
|-----------|--------|
| Language | C |
| Library | CS50 (`cs50.h`) |
| Standard Libraries | `stdio.h`, `string.h`, `ctype.h`, `math.h`, `stdlib.h` |
| Compiler | `clang` (via CS50 VS Code environment) |

---

## ▶️ How to Run

These programs run in the CS50 development environment. Use the CS50 VS Code codespace or install the CS50 library locally.
```bash
# Compile each program
clang -o scrabble scrabble.c -lcs50
clang -o readability readability.c -lcs50 -lm
clang -o substitution substitution.c -lcs50

# Run Scrabble
./scrabble

# Run Readability
./readability

# Run Substitution (key must be 26 unique alphabetic characters)
./substitution NQXPOMAFTRHLZGECYDBWSKJIVU
```

Or using the CS50 `make` shortcut:
```bash
make scrabble && ./scrabble
make readability && ./readability
make substitution && ./substitution NQXPOMAFTRHLZGECYDBWSKJIVU
```

---

## 🧠 How Substitution Works

The substitution cipher uses four functions:

| Function | Purpose |
|----------|---------|
| `len_check(string key)` | Confirms the key is exactly 26 characters |
| `alph_check(string key)` | Confirms all characters are alphabetic |
| `rep_check(string key)` | Confirms no character is repeated |
| `ciphering(char kee[], char text[])` | Encrypts the plaintext using the validated key |

The key is normalised to uppercase before encryption. Each plaintext letter is matched to its alphabet position and replaced with the corresponding key character, with case preserved from the original input. Non-alphabetic characters such as spaces and punctuation pass through unchanged.

---

## 🧠 How Readability Works

The Coleman-Liau index formula used:
```
index = 0.0588 × L − 0.296 × S − 15.8
```

Where:
- `L` = average number of letters per 100 words
- `S` = average number of sentences per 100 words

| Function | Purpose |
|----------|---------|
| `count_let(string text)` | Counts alphabetic characters |
| `count_space(string text)` | Counts words via spaces and null terminator |
| `count_fullstop(string text)` | Counts sentences via `.`, `!`, `?` |
| `printing(int grade)` | Outputs the grade, capped at "Before Grade 1" and "Grade 16+" |

---

## 🔗 Blog & Links

The full write-up for this week — covering the engineering decisions behind each program, what made the substitution cipher the most involved of the three, and what Week 2 teaches you about strings in C — is on the ParsaDev blog:

👉 [CS50 Week 2 C — Scrabble Scores, Readability Grades and Substitution Ciphers](https://www.parsadev.co.uk/post/cs50-week-2-c-scrabble-scores-readability-grades-and-substitution-ciphers)

Browse the rest of the CS50x series at [parsadev.co.uk/blog/categories/cs50x](https://www.parsadev.co.uk/blog/categories/cs50x).

---

## 📬 Contact

Built by Parsa — find more projects and writing at [parsadev.co.uk](https://www.parsadev.co.uk).

---

## 🎓 Credit

Problem sets designed by [Harvard CS50x 2026](https://cs50.harvard.edu/x/2026/). All code written independently as part of the course.