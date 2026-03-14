# 🗳️ CS50x Week 3 — Plurality, Tideman & Sorting Algorithms

> 📝 **Blog Post:** [CS50 Week 3 C — Plurality Voting, Tideman Ranked Pairs and Sorting Algorithms](https://www.parsadev.co.uk/post/cs50-week-3-c-plurality-voting-tideman-ranked-pairs-and-sorting-algorithms)
> 📚 **CS50x Series:** [All CS50x posts on ParsaDev](https://www.parsadev.co.uk/blog/categories/cs50x)
> 🌐 **Developer:** [parsadev.co.uk](https://www.parsadev.co.uk)

Four problem sets from CS50x Week 3, all written in C. This is the week where the course moves into proper algorithms and data structures — election systems, directed graphs, cycle detection, and empirical analysis of sorting algorithms. It is one of the most rewarding weeks in the course.

---

## 📌 What It Does

**Plurality** — Implements a first-past-the-post election. Candidates are passed as command-line arguments, voters enter their choices one at a time, and the program declares the winner. Ties are handled correctly — all candidates with the maximum vote count are printed.

**Tideman** — Implements the Tideman ranked pairs voting algorithm, which guarantees finding the Condorcet winner if one exists. Voters rank all candidates in order of preference. The program builds a preferences matrix, generates and sorts winning pairs by victory strength, and locks them into a directed graph while actively preventing cycles. The source of the final graph — the candidate with no incoming edges — is declared the winner.

**Sort (Analysis)** — Three pre-compiled sorting programs are timed against different inputs to identify which algorithm each one uses. Based on empirical benchmarking:
- `sort1` → Bubble Sort (highest upper bound, largest best/worst case gap)
- `sort2` → Merge Sort (consistent bounds, lowest floor)
- `sort3` → Selection Sort (high, stable lower bound regardless of input order)

---

## ✨ Features

**Plurality:**
- Command-line candidate input with `argc` / `argv`
- `strcmp`-based name matching for vote validation
- Two-pass `print_winner` — first finds the maximum, then prints all candidates matching it
- Handles ties with multiple winners on separate lines

**Tideman:**
- Full preferences matrix (`preferences[i][j]`) tracking head-to-head voter counts
- Pair generation using upper triangular traversal to avoid duplicate pairs
- Selection sort on pairs by net victory strength (winner votes minus loser votes)
- Cycle detection via `hasCycle` — walks backwards through locked edges from the proposed winner
- Adjacency matrix (`locked[i][j]`) representing the final directed graph
- Source detection in `print_winner` — finds the candidate with no incoming locked edges

---

## 🛠 Tech Stack

| Component | Detail |
|-----------|--------|
| Language | C |
| Library | CS50 (`cs50.h`) |
| Standard Libraries | `stdio.h`, `string.h` |
| Compiler | `clang` (via CS50 VS Code environment) |

---

## ▶️ How to Run
```bash
# Compile
clang -o plurality plurality.c -lcs50
clang -o tideman tideman.c -lcs50

# Run Plurality (list candidates as arguments)
./plurality Alice Bob Charlie

# Run Tideman (list candidates as arguments)
./tideman Alice Bob Charlie
```

Or using the CS50 `make` shortcut:
```bash
make plurality && ./plurality Alice Bob Charlie
make tideman && ./tideman Alice Bob Charlie
```

---

## 🧠 How Tideman Works

The algorithm runs in four stages:

| Stage | Function | Purpose |
|-------|----------|---------|
| 1. Tally | `record_preferences` | Builds the preferences matrix from each voter's ranked input |
| 2. Generate | `add_pairs` | Creates all pairs where one candidate is strictly preferred over the other |
| 3. Sort | `sort_pairs` | Sorts pairs in decreasing order of victory strength using selection sort |
| 4. Lock | `lock_pairs` + `hasCycle` | Locks pairs into the directed graph, skipping any that would create a cycle |
| 5. Winner | `print_winner` | Finds the source node — the candidate with no incoming locked edges |

### Cycle Detection

`hasCycle(int winner, int loser)` traverses the locked graph backwards from `winner`, following the chain of existing locked edges. If it reaches `loser`, the proposed new edge would complete a cycle and is skipped. If it reaches a node with no incoming locked edges, the edge is safe to add.

---

## 📊 Sorting Algorithm Analysis

| Program | Algorithm | Evidence |
|---------|-----------|---------|
| `sort1` | Bubble Sort | Highest upper bound and largest gap between best and worst case for 10,000 elements |
| `sort2` | Merge Sort | Consistent upper and lower bounds with the lowest overall floor |
| `sort3` | Selection Sort | High, stable lower bound regardless of whether input is sorted or random |

Full reasoning is in `answers.txt`.

---

## 🔗 Blog & Links

The full write-up — covering the engineering behind Tideman's cycle detection, how the preferences matrix feeds into the locked graph, and what the sorting analysis taught about real-world algorithmic performance — is on the ParsaDev blog:

👉 [CS50 Week 3 C — Plurality Voting, Tideman Ranked Pairs and Sorting Algorithms](https://www.parsadev.co.uk/post/cs50-week-3-c-plurality-voting-tideman-ranked-pairs-and-sorting-algorithms)

Browse the rest of the CS50x series at [parsadev.co.uk/blog/categories/cs50x](https://www.parsadev.co.uk/blog/categories/cs50x).

---

## 📬 Contact

Built by Parsa — find more projects and writing at [parsadev.co.uk](https://www.parsadev.co.uk).

---

## 🎓 Credit

Problem sets designed by [Harvard CS50x 2026](https://cs50.harvard.edu/x/2026/). All code written independently as part of the course.