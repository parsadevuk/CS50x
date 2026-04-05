# Parsa Vault — Stock Trading Simulator
#### Video Demo: https://youtube.com/shorts/yiVxjsERt3A?feature=share

## What is Parsa Vault?

Parsa Vault is a full-stack mobile application built with Flutter and Firebase that lets users simulate real stock market trading without risking any real money. Users start with a virtual cash balance of $10,000 and can buy and sell stocks using live market prices pulled from a financial data API. The app tracks their portfolio, transaction history, XP points, and level — and ranks them against all other users on a global leaderboard.

### Built on Week 9

This final project is a direct evolution of my Week 9 web application. In Week 9, I built a browser-based stock trading game in which players could buy and sell stocks, earn XP for their trading activity, and log in to save their progress. That web app established the core idea: gamified investing with an XP progression system and user accounts.

For this final project, I took that foundation and rebuilt it as a full native mobile application — expanding the feature set significantly, adding cloud sync via Firebase, introducing multiple sign-in methods, a global leaderboard, a guest mode, a news feed, and a production-ready deployment to both the Apple App Store (TestFlight) and Google Play Console. The XP system from Week 9 was redesigned with ten named levels, profit/loss bonuses and penalties, and a daily login reward. The login system was expanded from a simple session to support email/password, Google, Apple, and Microsoft SSO, as well as anonymous guest accounts with a data merge flow.

The application is live and deployed: available on Apple TestFlight for iOS testers and uploaded to Google Play Console for Android. It is not a prototype or a demo — it is a production-grade app with real authentication, real-time data, persistent cloud storage, and a complete user experience from onboarding through to account management.

The motivation behind Parsa Vault was to solve a genuine problem: most people who want to learn investing are afraid to lose real money while learning. Parsa Vault removes that barrier entirely. You can trade freely, make mistakes, reset your portfolio, and learn how markets work — all without financial risk. The gamification layer (XP, levels, leaderboard) adds motivation to keep practising and improving.

---

## Technology Stack

- **Flutter (Dart)** — cross-platform UI framework, runs natively on iOS and Android from a single codebase
- **Firebase Authentication** — handles all sign-in methods including email/password, Google, Apple, Microsoft SSO, and anonymous (guest) accounts
- **Cloud Firestore** — NoSQL cloud database storing user profiles, holdings, and transaction history in real time
- **Riverpod** — state management library for Flutter, used to manage authentication state, portfolio data, market prices, and navigation
- **Financial data API** — live stock prices fetched and refreshed every 30 seconds

---

## Key Features

### Guest Mode
Users can start trading immediately without creating an account. Firebase's anonymous authentication assigns them a real user ID behind the scenes, and their portfolio is stored in Firestore just like any registered user. When a guest decides to sign up or log in later, the app offers a merge dialog — "Two saves found" — showing their guest data (XP, level, cash) alongside their existing account's data, letting them choose which to keep. This two-step merge flow was one of the most technically complex features in the app: the guest's state must be captured before Firebase Auth switches to the new account, and then the chosen data must be written atomically.

### Authentication
The app supports five sign-in methods: email/password registration, Google SSO, Apple SSO, Microsoft SSO, and anonymous guest. All SSO flows are guest-aware — if a guest taps Google Sign In and connects to an existing account, the merge dialog appears. If the Google account is brand new, the guest's data is automatically copied over with no dialog needed, since there is no conflict.

### Portfolio Management
Users can buy and sell any stock available in the market. Each buy deducts from their cash balance; each sell adds to it. The app prevents overselling (you cannot sell more shares than you hold) and prevents overspending (you cannot spend more cash than you have). Cash is always floored to two decimal places on every transaction — never rounded up — to prevent floating-point drift accumulating over hundreds of trades.

### XP and Level System
Every action in the app earns XP. Buying a stock earns 10 XP. Selling at a profit earns 25 XP. Selling at a loss deducts 5 XP as a small penalty to discourage reckless trading. The first ever trade awards a one-time bonus of 50 XP. Daily logins award 5 XP. Deposits and withdrawals each earn 5 XP. Ten levels are defined — from *Apprentice* (0 XP) through *Trader*, *Investor*, *Analyst*, *Strategist*, *Portfolio Manager*, *Fund Manager*, *Market Expert*, *Wall Street Pro*, all the way to *Vault Master* (9,000 XP). Each level has a distinct icon colour displayed throughout the UI.

### Leaderboard
All registered and guest users are ranked by XP. The leaderboard shows each user's rank, avatar, username, level badge, and XP total. The current user's row is highlighted. The leaderboard refreshes on demand.

### News Feed
A news tab pulls financial headlines from an RSS feed and displays them as cards. Tapping a headline opens the full article in a detail view.

### Account Management
Registered users can update their full name, username, website, profile picture, city, and country. They can change their password and delete their account. Guest users see a simplified profile with a prompt to create an account or log in.

---

## Project File Structure

### `lib/main.dart`
Entry point of the application. Initialises Firebase and launches the app inside a Riverpod `ProviderScope`.

### `lib/app.dart`
Root widget. Listens to `authProvider` to decide which screen to show: splash, onboarding, welcome, or the main navigation shell. Also handles routing to email verification and SSO profile completion screens.

### `lib/firebase_options.dart`
Auto-generated by FlutterFire CLI. Contains Firebase project configuration (API keys, project IDs). **This file is excluded from the CS50 submission for security reasons** — it must be regenerated using `flutterfire configure` with the project's own Firebase credentials.

---

### `lib/models/`

- **`user.dart`** — The core `User` data class. Holds `id`, `fullName`, `username`, `email`, `cashBalance`, `xp`, `level`, `createdAt`, `lastLoginAt`, and optional fields for profile picture, city, country, and website. Includes `fromFirestore()` and `toFirestore()` serialisation methods.
- **`holding.dart`** — Represents a position in a single stock: the ticker symbol, number of shares held, and average purchase price.
- **`app_transaction.dart`** — Represents a single buy, sell, deposit, or withdrawal event with timestamp, ticker, quantity, and price.
- **`asset.dart`** — A live market asset with ticker, company name, current price, and percentage change.
- **`news_article.dart`** — A news headline with title, summary, source, URL, and publication date.

---

### `lib/providers/`

- **`auth_provider.dart`** — The most important provider in the app. Manages the entire authentication lifecycle: session restore on cold start, email/password login and registration, all three SSO flows (Google, Apple, Microsoft), anonymous guest sign-in, guest merge (`beginGuestLogin`, `finalizeMerge`), password change, and account deletion. Holds `AuthState` which tracks the current user, whether they are a guest, whether they are an SSO user, whether their email is verified, and whether there is a pending guest merge waiting for UI resolution.
- **`portfolio_provider.dart`** — Manages the user's portfolio: loads holdings from Firestore, handles buy and sell operations, deposit and withdrawal, portfolio reset, and calls into `historyProvider` to refresh the transaction list after every write. Also listens to auth state changes to reload data when the user switches accounts (e.g. after a guest logs in).
- **`history_provider.dart`** — Loads and holds the list of transactions. Refreshed after every trade and after login. Listens to auth state changes for user switches.
- **`market_provider.dart`** — Fetches and periodically refreshes live stock prices from the financial API every 30 seconds.
- **`leaderboard_provider.dart`** — Fetches all users sorted by XP for the leaderboard screen.
- **`news_provider.dart`** — Fetches and parses the financial news RSS feed.
- **`navigation_provider.dart`** — Tracks the active tab index for the bottom navigation bar.

---

### `lib/data/services/`

- **`auth_service.dart`** — All Firebase Authentication and Firestore user logic. Contains `GuestMergePreview` (a data class holding both the guest and existing user snapshots for the merge dialog), `_captureGuest()` (snapshots the anonymous user's UID and profile before SSO replaces the Firebase session), `beginGuestLogin()` (two-step email/password guest merge), `finalizeMerge()` (writes the chosen data and cleans up the guest document), and `_getOrCreateSsoProfile()` (finds or creates a Firestore profile for a new SSO user).
- **`portfolio_service.dart`** — Business logic for buy, sell, deposit, and withdraw. Applies `_floorToCents()` to every cash calculation to ensure balances are always floored to two decimal places, preventing floating-point drift (e.g. `5625.013012647001` becomes `5625.01`).
- **`market_service.dart`** — Calls the financial data API and maps the response to `Asset` objects.
- **`news_service.dart`** — Fetches and parses the financial news RSS feed into `NewsArticle` objects.

---

### `lib/data/repositories/`

- **`user_repository.dart`** — All Firestore reads and writes for user documents and subcollections. Includes `copyGameData()` which copies holdings and transactions from one user ID to another during a guest merge (used when a guest chooses to keep their own progress).
- **`holding_repository.dart`** — Reads and writes the `holdings` subcollection under a user's Firestore document.
- **`transaction_repository.dart`** — Reads and writes the `transactions` subcollection, ordered by timestamp descending.

---

### `lib/screens/`

- **`splash/splash_screen.dart`** — Animated splash screen shown on cold start while Firebase initialises and the session is restored.
- **`onboarding/onboarding_screen.dart`** — Shown once to new installs. Introduces the app with slides.
- **`auth/welcome_screen.dart`** — Entry point for unauthenticated users. Options to register, log in, continue with SSO, or play as a guest.
- **`auth/register_screen.dart`** — Email/password registration form with full name, username, email, and password fields.
- **`auth/login_screen.dart`** — Email/password login form. Guest-aware: if the current user is a guest, submitting triggers the merge flow instead of a standard login. Also handles the SSO guest merge dialog (`_GuestMergeSheet`) which shows both data options side by side with XP, level, and cash for each, forcing the user to make a choice before proceeding.
- **`auth/guest_upgrade_screen.dart`** — Shown when a guest taps "Create Account" from the profile screen. Lets them link their guest account to a real email/password account, preserving their portfolio.
- **`auth/sso_complete_profile_screen.dart`** — Shown to brand-new SSO users to let them set a username.
- **`auth/email_verification_screen.dart`** — Prompts email/password users to verify their email address.
- **`auth/forgot_password_screen.dart`** — Sends a Firebase password reset email.
- **`home/home_screen.dart`** — Main dashboard showing portfolio value, cash balance, holdings list, and XP progress bar.
- **`trade/trade_screen.dart`** — Buy and sell screen for a single stock. Shows current price, the user's current holding, and a quantity input.
- **`markets/markets_screen.dart`** — Live market list showing all available stocks with current price and percentage change.
- **`history/history_screen.dart`** — Full transaction history showing all buys, sells, deposits, and withdrawals.
- **`leaderboard/leaderboard_screen.dart`** — Global leaderboard ranked by XP.
- **`news/news_screen.dart`** and **`news/news_detail_screen.dart`** — News feed and article detail view.
- **`profile/profile_screen.dart`** — User profile with settings tiles. Guest-aware: hides the "User Profile" and "Change Password" tiles for guests, shows a banner to create an account or log in.
- **`profile/account_screen.dart`** — Edit profile fields: name, username, website, location, profile picture.

---

### `lib/widgets/`

Reusable UI components used across multiple screens:
- **`buttons/`** — `GoldButton`, `GoldOutlineButton`, `DestructiveButton`, `SsoButtons` (Google, Apple, Microsoft sign-in buttons)
- **`common/`** — `AssetTile`, `TransactionTile`, `LevelBadge`, `XpProgressBar`, `ConfirmationDialog`, `EmptyState`
- **`inputs/`** — `GoldInputField` (themed text input used throughout auth and profile screens)

---

### `lib/theme/`

- **`app_colors.dart`** — All colour constants: gold primary, dark backgrounds, semantic colours for profit (green) and loss (red).
- **`app_text_styles.dart`** — Typography scale using Google Fonts.
- **`app_theme.dart`** — The root `ThemeData` applied to the app.

---

### `lib/utils/`

- **`constants.dart`** — All magic numbers in one place: starting cash ($10,000), XP awards per action, level thresholds, level titles, price refresh interval (30 seconds).
- **`formatters.dart`** — Currency and number formatting helpers used throughout the UI.
- **`validators.dart`** — Form field validators for email, password strength, and username format.
- **`xp_calculator.dart`** — Pure functions to derive a user's level and progress percentage from their raw XP total.
- **`password_helper.dart`** — Password strength evaluation.

---

## Design Decisions

**Why Flutter?** Flutter produces a native app for both iOS and Android from a single Dart codebase. Given this was a solo project, maintaining two separate codebases (Swift + Kotlin) would have doubled the work. Flutter also has an excellent widget system that made building a polished, consistent UI straightforward.

**Why Firebase?** Firebase Authentication handles the complexity of SSO, anonymous accounts, and email verification out of the box. Firestore's real-time capabilities and its document/subcollection model map naturally to a user → holdings → transactions data shape. Using a managed backend also meant no server to provision, which kept the project focused on the application logic.

**Why floor cash instead of round?** When multiplying floating-point numbers, the result is rarely exact. For example, buying 3 shares at $18.75 gives a cost of `56.24999999999999` in IEEE 754 arithmetic. Rounding would produce `56.25` — correct. But over hundreds of trades these errors can accumulate in either direction, eventually producing a balance like `5625.013012647001`. Rounding up would give the user a fraction of a cent for free. Flooring to two decimal places on every write ensures the user can never gain money from floating-point imprecision, which is the conservative and correct approach for any financial application.

**Why a two-step guest merge?** The obvious approach — reading both the guest and the existing user's Firestore documents before signing in — fails in practice because Firestore security rules only allow a user to read their own document. A guest cannot query another user's document. The solution is to read the guest's own document first (allowed, since they are currently signed in as that guest), then sign in to the existing account, then read the existing account's own document (now allowed, since they are signed in as that user). This two-step approach is reliable regardless of how strict the security rules are.

**Why Riverpod over other state management?** Riverpod's provider system makes it easy to express dependencies between state (e.g. `portfolioProvider` depends on `authProvider`) and to listen to state changes reactively. The compile-time safety and testability of Riverpod's typed providers was a better fit for a project of this complexity than `setState` or `InheritedWidget` alone.

---

## How to Run

1. Clone the repository
2. Run `flutter pub get`
3. Add your own `google-services.json` (Android), `GoogleService-Info.plist` (iOS), and `lib/firebase_options.dart` from your Firebase project
4. Run `flutter run`

---

*This project was built as the CS50x 2026 final project.
