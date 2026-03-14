# 💻 CS50x Week 1 — Hello, Mario & Credit

> 📝 **Blog Post:** [CS50 Week 1 C — Hello World, Mario Pyramids and Credit Card Validation](https://www.parsadev.co.uk/post/cs50-week-1-c-hello-world-mario-pyramids-and-credit-card-validation)
> 📚 **CS50x Series:** [All CS50x posts on ParsaDev](https://www.parsadev.co.uk/blog/categories/cs50x)
> 🌐 **Developer:** [parsadev.co.uk](https://www.parsadev.co.uk)

Three problem sets from CS50x Week 1, all written in C. This is where the course shifts from theory into actual programming — and C does not let you get away with anything sloppy. These three programs cover user input, loops, functions, and a real-world algorithm, all from scratch.

---

## 📌 What It Does

**Hello** — Prompts the user for their name using the CS50 `get_string` function and prints a personalised greeting. Short and simple, but a solid introduction to how C handles strings and standard output.

**Mario** — Builds a double-sided pyramid of hash symbols (`#`) in the style of Super Mario Bros, scaled to a user-specified height between 1 and 8. Input is validated with a `do-while` loop that keeps prompting until a valid number is entered.

**Credit** — Takes a credit card number as a `long`, validates it using Luhn's algorithm, and identifies the card type — Visa, Mastercard, or American Express — based on the digit count and leading digits. Returns `INVALID` for anything that does not pass the checksum.

---

## ✨ Features

- Clean user input validation using `do-while` loops
- Mario pyramid rendered entirely with nested `for` loops and `printf`
- Credit card validator split into four modular functions for readability
- Luhn's algorithm implemented manually — no shortcuts
- Card type detection for Visa (13 and 16 digits), Mastercard (16 digits, prefixes 51–55), and Amex (15 digits, prefixes 34 and 37)
- Handles edge cases — invalid digit counts, failed checksums, and unrecognised prefixes all return `INVALID`

---

## 🛠 Tech Stack

| Component | Detail |
|-----------|--------|
| Language | C |
| Library | CS50 (`cs50.h`) |
| Standard Libraries | `stdio.h`, `math.h` |
| Compiler | `clang` (via CS50 VS Code environment) |

---

## ▶️ How to Run

These programs are written for the CS50 development environment. You can run them in the CS50 VS Code codespace or locally with the CS50 library installed.
```bash
# Compile each program
clang -o hello hello.c -lcs50
clang -o mario mario.c -lcs50
clang -o credit credit.c -lcs50 -lm

# Run Hello
./hello

# Run Mario
./mario

# Run Credit
./credit
```

Or using the CS50 `make` shortcut:
```bash
make hello && ./hello
make mario && ./mario
make credit && ./credit
```

---

## 🧠 How Credit Works

The credit card validator uses four separate functions:

| Function | Purpose |
|----------|---------|
| `dg(long cn)` | Counts the number of digits in the card number |
| `ct(long cn, int no)` | Extracts a single digit at a given position |
| `luhns_alg(long cn, int dg)` | Runs Luhn's algorithm and returns 1 (valid) or 0 (invalid) |
| `credit_type_checck(long cn)` | Identifies card type from digit count and leading digits |

Luhn's algorithm works by doubling every second digit from the right, summing the digits of any two-digit results, adding the undoubled digits, and checking whether the total is divisible by 10.

---

## 🔗 Blog & Links

The full write-up for this week — including what was technically challenging, how the logic was approached, and what C programming teaches you that higher-level languages do not — is on the ParsaDev blog:

👉 [CS50 Week 1 C — Hello World, Mario Pyramids and Credit Card Validation](https://www.parsadev.co.uk/post/cs50-week-1-c-hello-world-mario-pyramids-and-credit-card-validation)

Browse the rest of the CS50x series at [parsadev.co.uk/blog/categories/cs50x](https://www.parsadev.co.uk/blog/categories/cs50x).

---

## 📬 Contact

Built by Parsa — find more projects and writing at [parsadev.co.uk](https://www.parsadev.co.uk).

---

## 🎓 Credit

Problem sets designed by [Harvard CS50x 2026](https://cs50.harvard.edu/x/2026/). All code written independently as part of the course.