# CS50 Week 9 — C$50 Finance 💰

A full-stack stock trading web application built with Flask, SQLite, and Python as part of Harvard's CS50x 2026 course.

> 📝 Read the full blog post: [CS50 Week 9 Flask — Building C$50 Finance Stock Trading Web App](https://www.parsadev.co.uk/post/cs50-week-9-i-built-a-stock-trading-app-with-flask-and-i-m-never-looking-at-another-apology-templ)
>
> 📚 More CS50x blog posts: [parsadev.co.uk/blog/categories/cs50x](https://www.parsadev.co.uk/blog/categories/cs50x)
>
> 🌐 Developer website: [parsadev.co.uk](https://www.parsadev.co.uk)

## What It Does

C$50 Finance lets users manage a virtual stock portfolio. Users can register, log in, look up real stock prices, buy and sell shares, view their portfolio, and track their full transaction history. For a detailed walkthrough of how this was built, check out the [full blog post on ParsaDev](https://www.parsadev.co.uk/post/cs50-week-9-i-built-a-stock-trading-app-with-flask-and-i-m-never-looking-at-another-apology-templ).

## Features

- **Register & Login** — secure user authentication with hashed passwords
- **Quote** — look up real-time stock prices via external API
- **Buy** — purchase shares of any valid stock symbol
- **Sell** — sell shares you currently own
- **Portfolio (Index)** — view all owned stocks, current prices, and net worth
- **History** — full transaction log of every buy and sell
- **Change Password** — securely update your account password
- **Deposit** — add cash to your account (password confirmed)
- **Withdraw** — withdraw cash from your account (password confirmed)

## Tech Stack

- Python
- Flask
- SQLite
- Jinja2
- Bootstrap 5
- CS50 SQL Library

## How to Run

1. Clone the repository
2. Navigate into the finance folder
```bash
cd finance
```
3. Install dependencies
```bash
pip install -r requirements.txt
```
4. Run the app
```bash
flask run
```
5. Visit the URL shown in your terminal

## Database Schema

**users**
- id, username, hash, cash

**purchases**
- id, user_id, symbol, name, shares, price, timestamp

## Notes

- Every route includes server-side validation and humorous error handling for HTML manipulation attempts
- Sales are recorded as negative share values so transaction history always reflects the full picture
- Deposit and Withdraw transactions are recorded in the purchases table with symbols DEPOSIT and WITHDRAW

## Blog & Links

- 📝 [Full project blog post](https://www.parsadev.co.uk/post/cs50-week-9-i-built-a-stock-trading-app-with-flask-and-i-m-never-looking-at-another-apology-templ)
- 📚 [All CS50x blog posts](https://www.parsadev.co.uk/blog/categories/cs50x)
- 🌐 [ParsaDev — Python, Swift & AI Development](https://www.parsadev.co.uk)

## Credit

Built as part of [Harvard CS50x 2026](https://cs50.harvard.edu/x/2026/) — Week 9 Problem Set.