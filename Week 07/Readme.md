# 🗄️ CS50x Week 7 — Songs, Movies & Fiftyville

> 📝 **Blog Post:** [CS50 Week 7 SQL — Spotify Songs, IMDb Movies and the Fiftyville Mystery](https://www.parsadev.co.uk/post/cs50-week-7-sql-spotify-songs-imdb-movies-and-the-fiftyville-mystery)
> 📚 **CS50x Series:** [All CS50x posts on ParsaDev](https://www.parsadev.co.uk/blog/categories/cs50x)
> 🌐 **Developer:** [parsadev.co.uk](https://www.parsadev.co.uk)

Three problem sets from CS50x Week 7, all written in SQL. This is the week the course introduces databases — and it does so through three very different challenges: analysing Spotify's top songs, querying an IMDb movie database across five joined tables, and solving a crime using nothing but SQL queries against a town's records.

---

## 📌 What It Does

**Songs** — Eight SQL queries against a Spotify database of the top 100 streamed songs of 2018. Covers basic `SELECT`, `ORDER BY`, `LIMIT`, `WHERE` with multiple conditions, `AVG`, subqueries, and `LIKE` with wildcards.

**Movies** — Thirteen SQL queries against a five-table IMDb database covering movies, people, ratings, stars, and directors. Queries progress from simple year filters to multi-table `JOIN` chains, nested subqueries, `DISTINCT`, and `LIMIT`-based ranking.

**Fiftyville** — A SQL mystery: the CS50 duck was stolen on 28 July from Humphrey Street, Fiftyville. Using only SQL queries against a town database of crime reports, interviews, CCTV logs, ATM records, phone calls, flights, and passenger manifests — the thief, their accomplice, and their escape destination are identified.

---

## 🎵 Songs Queries

| File | Query |
|------|-------|
| `1.sql` | List the names of all songs |
| `2.sql` | List all songs in increasing order of tempo |
| `3.sql` | Top 5 longest songs in descending order of duration |
| `4.sql` | Songs with danceability, energy, and valence all above 0.75 |
| `5.sql` | Average energy of all songs |
| `6.sql` | Songs by Post Malone (subquery — no hardcoded IDs) |
| `7.sql` | Average energy of songs by Drake (subquery) |
| `8.sql` | Songs featuring other artists (`LIKE '%feat.%'`) |

---

## 🎬 Movies Queries

| File | Query |
|------|-------|
| `1.sql` | All movies released in 2008 |
| `2.sql` | Birth year of Emma Stone |
| `3.sql` | All movies released 2018 or later, alphabetically |
| `4.sql` | Count of movies with a 10.0 IMDb rating |
| `5.sql` | All Harry Potter movies with title and year, chronologically |
| `6.sql` | Average rating of all movies released in 2012 |
| `7.sql` | All 2010 movies and their ratings, sorted by rating DESC then title ASC |
| `8.sql` | All people who starred in Toy Story |
| `9.sql` | ID and name of all people who starred in a 2004 movie, ordered by birth year |
| `10.sql` | Names of all directors of movies rated 9.0 or above (DISTINCT) |
| `11.sql` | Top 5 highest-rated Chadwick Boseman films |
| `12.sql` | Movies starring both Johnny Depp and Helena Bonham Carter |
| `13.sql` | All actors who starred in a film with Kevin Bacon (born 1958), excluding Kevin Bacon |

---

## 🔍 Fiftyville — The Mystery

**The theft took place on 28 July 2021 on Humphrey Street.**

| Finding | Detail |
|---------|--------|
| 🦹 Thief | Bruce |
| ✈️ Escaped to | New York City |
| 🤝 Accomplice | Robin |

### Investigation Method

The solution was built as a series of intersecting SQL sets, narrowing suspects at each step:

1. **Crime scene report** — Confirmed the theft at the bakery on Humphrey Street, 28 July 2021
2. **Witness interviews** — Three witnesses: thief left via bakery car park within 10 minutes; thief withdrew cash from ATM on Leggett Street that morning; thief made a call under 60 seconds and asked accomplice to book the first available flight out the next day
3. **Bakery CCTV** — Found licence plates of vehicles that exited between 10:00 and 10:25 AM
4. **ATM records** — Found accounts that made withdrawals on Leggett Street that morning
5. **Flight records** — Found passengers on the earliest flight out of Fiftyville on 29 July
6. **INTERSECT** — Cross-referenced all three sets to narrow to three suspects: Luca, Diana, Bruce
7. **Phone call records** — Filtered calls under 60 seconds on 28 July; narrowed to Bruce and Diana
8. **Accomplice trace** — Traced the receiver of Bruce's call → Robin purchased the ticket

Full query log with reasoning comments is in `log.sql`.

---

## 🛠 Tech Stack

| Component | Detail |
|-----------|--------|
| Language | SQL (SQLite) |
| Databases | `songs.db`, `movies.db`, `fiftyville.db` |
| Tools | `sqlite3` (CS50 VS Code environment) |

---

## ▶️ How to Run
```bash
# Songs
cat 1.sql | sqlite3 songs.db
cat 6.sql | sqlite3 songs.db

# Movies
cat 1.sql | sqlite3 movies.db
cat 13.sql | sqlite3 movies.db

# Fiftyville — run queries interactively
sqlite3 fiftyville.db
# Then paste queries from log.sql

# Or redirect output to a file
cat 11.sql | sqlite3 movies.db > output.txt
```

---

## 🔗 Blog & Links

The full write-up — covering how the queries were built, the Fiftyville investigation step by step, and what Week 7 teaches about thinking in SQL — is on the ParsaDev blog:

👉 [CS50 Week 7 SQL — Spotify Songs, IMDb Movies and the Fiftyville Mystery](https://www.parsadev.co.uk/post/cs50-week-7-sql-spotify-songs-imdb-movies-and-the-fiftyville-mystery)

Browse the rest of the CS50x series at [parsadev.co.uk/blog/categories/cs50x](https://www.parsadev.co.uk/blog/categories/cs50x).

---

## 📬 Contact

Built by Parsa — find more projects and writing at [parsadev.co.uk](https://www.parsadev.co.uk).

---

## 🎓 Credit

Problem sets designed by [Harvard CS50x 2026](https://cs50.harvard.edu/x/2026/). All code written independently as part of the course.