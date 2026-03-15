# 🧬 CS50x Week 5 — Inheritance & Speller

> 📝 **Blog Post:** [CS50 Week 5 C — Blood Type Inheritance and Building a Spell Checker with a Hash Table](https://www.parsadev.co.uk/post/cs50-week-5-c-blood-type-inheritance-and-building-a-spell-checker-with-a-hash-table)
> 📚 **CS50x Series:** [All CS50x posts on ParsaDev](https://www.parsadev.co.uk/blog/categories/cs50x)
> 🌐 **Developer:** [parsadev.co.uk](https://www.parsadev.co.uk)

Two problem sets from CS50x Week 5, both written in C. This is the week where memory management is the whole job — recursive heap allocation, pointer-based trees, hash tables, linked list chaining, and the kind of careful `free()` discipline that Valgrind rewards you for getting right.

---

## 📌 What It Does

**Inheritance** — Simulates blood type inheritance across three generations of a family. Each family member is a dynamically allocated `struct` with two parent pointers and two blood type alleles. The family tree is built recursively, with each child inheriting one random allele from each parent. The oldest generation has alleles assigned at random. The entire tree is freed recursively using post-order traversal — parents freed before children.

**Speller (`dictionary.c`)** — Implements a spell checker that loads a dictionary of up to 143,091 words into a hash table of linked lists, then checks each word in a text file against it. Reports all misspellings and benchmarks time spent in `load`, `check`, `size`, and `unload`.

---

## ✨ Features

**Inheritance:**
- Recursive `create_family` builds the full tree top-down, allocating each `person` with `malloc`
- Allele inheritance picks one random allele from each parent using `rand() % 2`
- `free_family` uses post-order recursion — frees the leaves before the nodes above them
- Base case sets both parent pointers to `NULL` and assigns alleles via `random_allele()`

**Speller:**
- Hash function uses the second character of each word (case-normalised) to distribute across 26 buckets — avoids the naive first-letter approach
- `load` inserts each new node at the head of the linked list for O(1) insertion
- `check` uses `strcasecmp` for case-insensitive comparison, walking the bucket chain
- `size` returns a global `wordCount` integer incremented on each load — O(1)
- `unload` walks every bucket, frees every node in each chain, and resets table pointers to `NULL`
- No memory leaks — verified with Valgrind

---

## 🛠 Tech Stack

| Component | Detail |
|-----------|--------|
| Language | C |
| Standard Libraries | `stdio.h`, `stdlib.h`, `stdbool.h`, `string.h`, `strings.h`, `ctype.h`, `time.h` |
| CS50 Speller scaffold | `speller.c`, `dictionary.h`, `Makefile` (provided by CS50) |
| Compiler | `make` (CS50 VS Code environment) |
| Memory checker | `valgrind` |

---

## ▶️ How to Run
```bash
# Inheritance
make inheritance
./inheritance

# Speller — compile with make speller (not make dictionary)
make speller

# Run with default large dictionary
./speller texts/lalaland.txt

# Run with small dictionary
./speller dictionaries/small texts/cat.txt

# Check for memory leaks
valgrind ./speller texts/cat.txt
```

---

## 🧠 How Inheritance Works

| Function | Purpose |
|----------|---------|
| `create_family(int generations)` | Recursively allocates the full family tree; assigns alleles from parents or randomly at the oldest generation |
| `free_family(person *p)` | Recursively frees the tree post-order — parents freed before the child node |
| `random_allele()` | Returns a random `'A'`, `'B'`, or `'O'` character |
| `print_family(person *p, int generation)` | Prints the tree with indented generation labels |

**Recursion pattern:**
- If `generations > 1` → build both parents first, then assign alleles from them
- If `generations == 1` → set parents to `NULL`, assign alleles randomly

---

## 🧠 How Speller Works

| Function | Purpose |
|----------|---------|
| `load` | Opens dictionary, reads each word, hashes it, and inserts a new node at the head of the correct bucket |
| `hash` | Returns a bucket index based on the second character of the word, modulo N (26) |
| `check` | Hashes the word, walks the bucket's linked list, uses `strcasecmp` for case-insensitive matching |
| `size` | Returns the global `wordCount` — incremented during `load` |
| `unload` | Iterates all buckets, frees every node in each chain, resets pointers to `NULL` |

**Hash table structure:**
```
table[0] → node → node → NULL
table[1] → node → NULL
table[2] → NULL
...
table[25] → node → node → node → NULL
```

---

## 🔗 Blog & Links

The full write-up — covering the recursive memory patterns in Inheritance, the engineering decisions behind the hash function and linked list design in Speller, and what Week 5 teaches about owning every byte you allocate — is on the ParsaDev blog:

👉 [CS50 Week 5 C — Blood Type Inheritance and Building a Spell Checker with a Hash Table](https://www.parsadev.co.uk/post/cs50-week-5-c-blood-type-inheritance-and-building-a-spell-checker-with-a-hash-table)

Browse the rest of the CS50x series at [parsadev.co.uk/blog/categories/cs50x](https://www.parsadev.co.uk/blog/categories/cs50x).

---

## 📬 Contact

Built by Parsa — find more projects and writing at [parsadev.co.uk](https://www.parsadev.co.uk).

---

## 🎓 Credit

Problem sets designed by [Harvard CS50x 2026](https://cs50.harvard.edu/x/2026/). All code written independently as part of the course.