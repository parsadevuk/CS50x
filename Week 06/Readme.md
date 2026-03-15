# 🐍 CS50x Week 6 — Python & DNA

> 📝 **Blog Post:** [CS50 Week 6 Python — Rewriting C Problems in Python and DNA Profiling with STR Matching](https://www.parsadev.co.uk/post/cs50-week-6-python-rewriting-c-problems-in-python-and-dna-profiling-with-str-matching)
> 📚 **CS50x Series:** [All CS50x posts on ParsaDev](https://www.parsadev.co.uk/blog/categories/cs50x)
> 🌐 **Developer:** [parsadev.co.uk](https://www.parsadev.co.uk)

Five problem sets from CS50x Week 6, all written in Python. This is the week the language changes — five weeks of C gives way to Python, and the contrast is immediate. The first four problems are sentimental re-implementations of problems from earlier weeks. DNA is a brand-new challenge: a forensic profiling program that identifies individuals from a DNA sequence using STR matching against a CSV database.

---

## 📌 What It Does

**Hello** — Prompts the user for their name using `get_string` from the CS50 library and prints a personalised greeting using an f-string. Four lines of Python replacing eight lines of C.

**Mario** — Recreates the double pyramid from Week 1 in Python. Input validation uses a `while True` loop with `get_int`. Each row is printed using Python string multiplication — spaces, hashes, gap, hashes — in a single `print` call.

**Credit** — Validates a credit card number using Luhn's algorithm, then identifies the card type (Visa, Mastercard, or Amex) from the digit count and leading digits. Uses `math.log10` to count digits, a nested `digits_of` function returning a list, and Python list slicing to extract leading digits.

**Readability** — Counts letters, words, and sentences in a block of text and computes the Coleman-Liau reading grade index. Letters counted via `string.ascii_letters`, words tracked through a space-counting condition, sentences via `.`, `!`, and `?` detection.

**DNA** — Reads a CSV database of STR counts per person and a DNA sequence file, computes the longest consecutive run of each STR in the sequence, and matches the result against the database to identify the individual. Prints `No match` if no exact match is found.

---

## ✨ Features

**Hello:**
- One-line f-string output: `print(f"hello, {name}")`
- Uses CS50's `get_string` for input

**Mario:**
- String multiplication replaces three nested `for` loops from the C version
- Input validation loop rejects values outside 1–8

**Credit:**
- `luhn_checksum` uses a nested `digits_of` helper returning `[int(d) for d in str(n)]`
- Digit count computed with `math.log10` — no string conversion needed
- Leading digits extracted cleanly with `str(cardNumber)[:1]` and `[:2]`

**Readability:**
- `string.ascii_letters` used to check membership rather than `isalpha`
- Word count handles first word (index 0, not a space) and subsequent words (space followed by non-space)
- Same Coleman-Liau formula as Week 2, implemented in Python

**DNA:**
- CSV parsed with `csv.reader`; header row extracted with `next()` and first column removed
- STR counts in each row converted to `int` during initial parse for clean comparison
- `longest_match` uses a sliding window — for each position in the sequence, counts how many times the subsequence repeats consecutively
- Final match compares a built list of STR counts against each database row

---

## 🛠 Tech Stack

| Component | Detail |
|-----------|--------|
| Language | Python 3 |
| Library | CS50 (`cs50`) for Hello, Mario, Readability |
| Standard Modules | `math`, `string`, `csv`, `sys` |
| Runtime | CS50 VS Code environment |

---

## ▶️ How to Run
```bash
# Hello
python hello.py

# Mario
python mario.py

# Credit
python credit.py

# Readability
python readability.py

# DNA — requires a database CSV and a sequence text file
python dna.py databases/small.csv sequences/1.txt
python dna.py databases/large.csv sequences/5.txt
```

---

## 🧠 How DNA Works

| Step | Detail |
|------|--------|
| Parse CSV | `csv.reader` reads the database; `next()` extracts the header; first column (name) removed to leave STR names only |
| Convert types | STR count strings converted to `int` during initial row parse |
| Read sequence | DNA text file read into memory as a single string |
| Compute STRs | `longest_match` called for each STR in the header — returns the longest consecutive run count |
| Match | Built list of counts compared against each row; matching row's name is printed |
| No match | If no row matches exactly, prints `No match` |

### `longest_match` — Sliding Window Logic

For every position `i` in the DNA sequence:
1. Start a counter at 0
2. Check if the subsequence appears at position `i + count * len(subsequence)`
3. If yes, increment the counter and check again
4. If no, break and record the count
5. Return the maximum count found across all positions

---

## 🔗 Blog & Links

The full write-up — covering what changes when you rewrite C programs in Python, how the DNA STR matching algorithm works, and what the language switch in Week 6 actually teaches you — is on the ParsaDev blog:

👉 [CS50 Week 6 Python — Rewriting C Problems in Python and DNA Profiling with STR Matching](https://www.parsadev.co.uk/post/cs50-week-6-python-rewriting-c-problems-in-python-and-dna-profiling-with-str-matching)

Browse the rest of the CS50x series at [parsadev.co.uk/blog/categories/cs50x](https://www.parsadev.co.uk/blog/categories/cs50x).

---

## 📬 Contact

Built by Parsa — find more projects and writing at [parsadev.co.uk](https://www.parsadev.co.uk).

---

## 🎓 Credit

Problem sets designed by [Harvard CS50x 2026](https://cs50.harvard.edu/x/2026/). All code written independently as part of the course.