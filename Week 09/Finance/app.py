import os

from cs50 import SQL
from flask import Flask, flash, redirect, render_template, request, session
from flask_session import Session
from werkzeug.security import check_password_hash, generate_password_hash

from helpers import apology, login_required, lookup, usd
# Login with user:"abc" and password: "12345678"
# Configure application
app = Flask(__name__)

# Custom filter
app.jinja_env.filters["usd"] = usd

# Configure session to use filesystem (instead of signed cookies)
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

# Configure CS50 Library to use SQLite database
db = SQL("sqlite:///finance.db")

# Configure CS50 Library to use SQLite database if does not exist
def init_db():
    db.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            username TEXT NOT NULL,
            hash TEXT NOT NULL,
            cash NUMERIC NOT NULL DEFAULT 10000.00
        )
    """)
    db.execute("""
        CREATE UNIQUE INDEX IF NOT EXISTS username ON users (username)
    """)
    db.execute("""
        CREATE TABLE IF NOT EXISTS purchases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            symbol TEXT NOT NULL,
            name TEXT NOT NULL,
            shares INTEGER NOT NULL,
            price REAL NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id)
        )
    """)
    db.execute("""
        CREATE INDEX IF NOT EXISTS purchases_user_id ON purchases (user_id)
    """)

init_db()

@app.after_request
def after_request(response):
    """Ensure responses aren't cached"""
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response


@app.route("/")
@login_required
def index():
    """Show portfolio of stocks"""
    user = db.execute("SELECT cash FROM users WHERE id = ?", session["user_id"])

    if not user:
        return apology("oi! what's going on!!! user not found mate!", 400)

    cash = user[0]["cash"]
    purchases = db.execute(
        "SELECT symbol, name, SUM(shares) as total_shares FROM purchases WHERE user_id = ? GROUP BY symbol HAVING SUM(shares) > 0", session["user_id"])

    portfolio = []
    holdingsWorth = 0

    for row in purchases:
        stock = lookup(row["symbol"])
        if stock is None:
            continue
        price = stock["price"]
        individualEquity = price * row["total_shares"]
        holdingsWorth += individualEquity
        portfolio.append({
            "symbol": row["symbol"],
            "name": row["name"],
            "shares": row["total_shares"],
            "price": price,
            "individualEquity": individualEquity
        })

    netWorth = cash + holdingsWorth

    return render_template("index.html", portfolio=portfolio, cash=cash, netWorth=netWorth, holdingsWorth=holdingsWorth)


@app.route("/buy", methods=["GET", "POST"])
@login_required
def buy():
    """Buy shares of stock"""
    if request.method == "POST":

        symbol = request.form.get("symbol")
        shares = request.form.get("shares")

        # check  symbol exist
        if not symbol:
            return apology("caught you! 🕵️ symbol is required mate!", 400)

        # check if shares exist
        if not shares:
            return apology("caught you! 🕵️ shares is required mate!", 400)

        # check if shares is a positive integer
        try:
            shares = int(shares)
            if shares < 1:
                return apology("cheeky hacker! 😤 shares must be a positive number!", 400)
        except ValueError:
            return apology("oi! 🕵️ shares must be a whole number and posotive mate!", 400)

        # look for stock
        try:
            stock = lookup(symbol)
            if stock is None:
                return apology("symbol does not exist", 400)
        except Exception:
            return apology("something went wrong with symbols", 400)

        totalCost = stock["price"] * shares

        rows = db.execute("SELECT cash FROM users WHERE id = ?", session["user_id"])
        cash = rows[0]["cash"]

        # check sufficient balance
        if cash < totalCost:
            return apology("oi! 😱 you can't afford that mate!, relax. come down. try some thing you can effort", 400)

        # mew balance
        db.execute("UPDATE users SET cash = ? WHERE id = ?", cash - totalCost, session["user_id"])
        db.execute("INSERT INTO purchases (user_id, symbol, name, shares, price) VALUES (?, ?, ?, ?, ?)",
                   session["user_id"], stock["symbol"], stock["name"], shares, stock["price"])

        # redirect to home page
        return redirect("/")

    else:
        return render_template("buy.html")


@app.route("/history")
@login_required
def history():
    """Show history of transactions"""
    transactions = db.execute(
        "SELECT symbol, shares, price, timestamp FROM purchases WHERE user_id = ? ORDER BY timestamp DESC", session["user_id"])

    return render_template("history.html", transactions=transactions)


@app.route("/login", methods=["GET", "POST"])
def login():
    """Log user in"""

    # Forget any user_id
    session.clear()

    # User reached route via POST (as by submitting a form via POST)
    if request.method == "POST":
        # Ensure username was submitted
        if not request.form.get("username"):
            return apology("must provide username", 403)

        # Ensure password was submitted
        elif not request.form.get("password"):
            return apology("must provide password", 403)

        # Query database for username
        rows = db.execute(
            "SELECT * FROM users WHERE username = ?", request.form.get("username").lower()
        )

        # Ensure username exists and password is correct
        if len(rows) != 1 or not check_password_hash(
            rows[0]["hash"], request.form.get("password")
        ):
            return apology("invalid username and/or password", 403)

        # Remember which user has logged in
        session["user_id"] = rows[0]["id"]

        # Redirect user to home page
        return redirect("/")

    # User reached route via GET (as by clicking a link or via redirect)
    else:
        return render_template("login.html")


@app.route("/logout")
def logout():
    """Log user out"""

    # Forget any user_id
    session.clear()

    # Redirect user to login form
    return redirect("/")


@app.route("/quote", methods=["GET", "POST"])
@login_required
def quote():
    """Get stock quote."""
    if request.method == "POST":

        symbol = request.form.get("symbol")
        if not symbol:
            return apology("must provide a symbol", 400)
        try:
            stock = lookup(symbol)
            if stock is None:
                return apology("symbol does not exist", 400)
        except Exception:
            return apology("something went wrong with symbols", 400)

        return render_template("quoted.html", stock=stock)
    else:
        return render_template("quote.html")


@app.route("/register", methods=["GET", "POST"])
def register():
    """Register user"""
    if request.method == "POST":

        if not request.form.get("username"):
            return apology("caught you! 🕵️ nice try hacking the HTML, username is required mate!", 400)

        elif len(request.form.get("username")) < 4:
            return apology("sneaky HTML hacker! 😏 username must be at least 4 characters!", 400)

        elif not request.form.get("password"):
            return apology("oi HTML hacker! 🚨 did you really just remove the password field?!", 400)

        elif len(request.form.get("password")) < 8:
            return apology("cheeky hacker! 😤 password must be at least 8 characters, i am watching you!", 400)

        elif not request.form.get("confirmation"):
            return apology("seriously?! 🤦 you deleted the confirmation field? html hacker detected!", 400)

        elif request.form.get("password") != request.form.get("confirmation"):
            return apology("whaaaat!! 😱 html hacker alert! passwords do not match!", 400)

        # Check if username already exists
        rows = db.execute("SELECT * FROM users WHERE username = ?",
                          request.form.get("username").lower())

        if len(rows) != 0:
            return apology("oi! 🕵️ that username already exists mate!", 400)

        # Hashing the password
        hashed_password = generate_password_hash(request.form.get("password"))

        db.execute("INSERT INTO users (username, hash) VALUES (?, ?)",
                   request.form.get("username").lower(), hashed_password)

        return redirect("/login")

    else:
        return render_template("register.html")


@app.route("/sell", methods=["GET", "POST"])
@login_required
def sell():
    """Sell shares of stock"""
    if request.method == "POST":
        symbol = request.form.get("symbol")
        shares = request.form.get("shares")

        if not symbol:
            return apology("oi! 🕵️ caught you! symbol is required mate!", 400)
        if not shares:
            return apology("oi! 🕵️ caught you! shares is required mate!", 400)
        try:
            shares = int(shares)
            if shares < 1:
                return apology("cheeky hacker! 😤 shares must be a positive number!", 400)
        except ValueError:
            return apology("error in shares, must be a whole number mate!")
        owned = db.execute(
            "SELECT SUM(shares) as total_shares FROM purchases WHERE user_id = ? AND symbol = ?", session["user_id"], symbol)
        if not owned or owned[0]["total_shares"] is None or owned[0]["total_shares"] <= 0:
            return apology("sneaky hacker! 😏 you don't own that stock mate!", 400)

        ownedShares = owned[0]["total_shares"]
        if shares > ownedShares:
            return apology("whaaaat!! 😱 you don't own that many shares mate! ", 400)

        try:
            stock = lookup(symbol)
            if stock is None:
                return apology("something went wrong with symbols in selling function", 400)
        except Exception:
            return apology("something went wrong with symbols", 400)
        saleValue = stock["price"] * shares
        user = db.execute("SELECT cash FROM users WHERE id = ?", session["user_id"])
        cash = user[0]["cash"]
        db.execute("UPDATE users SET cash = ? Where id = ?", cash + saleValue, session["user_id"])
        db.execute("INSERT INTO purchases (user_id, symbol, name, shares, price) VALUES (?, ?, ?, ?, ?)",
                   session["user_id"], stock["symbol"], stock["name"], -shares, stock["price"])
        return redirect("/")

    else:
        stocks = db.execute(
            "SELECT symbol FROM purchases WHERE user_id = ? GROUP BY symbol HAVING SUM(shares) > 0", session["user_id"])
        return render_template("sell.html", stocks=stocks)


@app.route("/change_password", methods=["GET", "POST"])
@login_required
def change_password():
    """Change user password"""
    if request.method == "POST":

        current_password = request.form.get("current_password")
        new_password = request.form.get("new_password")
        confirmation = request.form.get("confirmation")

        if not current_password:
            return apology("oi! 🕵️ current password is required mate!", 400)
        if not new_password:
            return apology("oi! 🕵️ new password is required mate!", 400)
        if not confirmation:
            return apology("oi! 🕵️ confirmation is required mate!", 400)

        if len(new_password) < 8:
            return apology("cheeky hacker! 😤 new password must be at least 8 characters!", 400)

        if new_password != confirmation:
            return apology("whaaaat!! 😱 new passwords do not match mate!", 400)

        rows = db.execute("SELECT hash FROM users WHERE id = ?", session["user_id"])

        if not check_password_hash(rows[0]["hash"], current_password):
            return apology("oi! 🚨 current password is incorrect mate!", 400)

        new_hash = generate_password_hash(new_password)
        db.execute("UPDATE users SET hash = ? WHERE id = ?", new_hash, session["user_id"])

        return redirect("/")

    else:
        return render_template("change_password.html")


@app.route("/deposit", methods=["GET", "POST"])
@login_required
def deposit():
    """Allow user to deposit cash"""
    if request.method == "POST":

        password = request.form.get("password")
        amount = request.form.get("sum")

        if not password:
            return apology("oi! 🕵️ password is required mate!", 400)
        if not amount:
            return apology("oi! 🕵️ amount is required mate!", 400)

        try:
            amount = float(amount)
            if amount < 100:
                return apology("cheeky hacker! 😤 minimum deposit is $100 mate!", 400)
        except ValueError:
            return apology("oi! 🕵️ amount must be a number mate!", 400)

        rows = db.execute("SELECT hash FROM users WHERE id = ?", session["user_id"])

        if not check_password_hash(rows[0]["hash"], password):
            return apology("oi! 🚨 incorrect password mate!", 400)

        user = db.execute("SELECT cash FROM users WHERE id = ?", session["user_id"])
        cash = user[0]["cash"]

        db.execute("UPDATE users SET cash = ? WHERE id = ?", cash + amount, session["user_id"])
        db.execute("INSERT INTO purchases (user_id, symbol, name, shares, price) VALUES (?, ?, ?, ?, ?)",
                   session["user_id"], "DEPOSIT", "Cash Deposit", 0, amount)

        return redirect("/")

    else:
        return render_template("deposit.html")


@app.route("/withdraw", methods=["GET", "POST"])
@login_required
def withdraw():
    """Allow user to withdraw cash"""
    if request.method == "POST":

        password = request.form.get("password")
        amount = request.form.get("sum")

        if not password:
            return apology("oi! 🕵️ password is required mate!", 400)
        if not amount:
            return apology("oi! 🕵️ amount is required mate!", 400)

        try:
            amount = float(amount)
            if amount < 100:
                return apology("cheeky hacker! 😤 minimum withdrawal is $100 mate!", 400)
        except ValueError:
            return apology("oi! 🕵️ amount must be a number mate!", 400)

        rows = db.execute("SELECT hash FROM users WHERE id = ?", session["user_id"])

        if not check_password_hash(rows[0]["hash"], password):
            return apology("oi! 🚨 incorrect password mate!", 403)

        user = db.execute("SELECT cash FROM users WHERE id = ?", session["user_id"])
        cash = user[0]["cash"]

        if amount > cash:
            return apology("oi! 😱 you don't have enough cash to withdraw mate!", 400)

        db.execute("UPDATE users SET cash = ? WHERE id = ?", cash - amount, session["user_id"])
        db.execute("INSERT INTO purchases (user_id, symbol, name, shares, price) VALUES (?, ?, ?, ?, ?)",
                   session["user_id"], "WITHDRAW", "Cash Withdrawal", 0, amount)

        return redirect("/")

    else:
        return render_template("withdraw.html")
