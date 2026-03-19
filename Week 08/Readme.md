# 🌐 CS50x Week 8 — Trivia & Homepage

> 📝 **Blog Post:** [CS50 Week 8 HTML CSS JavaScript — Building a Trivia App and a Seven-Theme Developer Portfolio](https://www.parsadev.co.uk/post/cs50-week-8-html-css-javascript-building-a-trivia-app-and-a-seven-theme-developer-portfolio)
> 📚 **CS50x Series:** [All CS50x posts on ParsaDev](https://www.parsadev.co.uk/blog/categories/cs50x)
> 🌐 **Developer:** [parsadev.co.uk](https://www.parsadev.co.uk)

Two problem sets from CS50x Week 8, both built with HTML, CSS, and JavaScript. Trivia is a focused DOM manipulation exercise. Homepage is a full four-page developer portfolio for ParsaDev — with a seven-theme colour system, Bootstrap 5 responsive layout, localStorage persistence, and Intersection Observer scroll animations.

---

## 📌 What It Does

**Trivia** — A two-question quiz page. Part 1 is multiple choice: buttons turn green or red on click, with feedback text appearing below the question. Part 2 is free response: the input field changes colour on submission and feedback is displayed. All interactivity is handled with vanilla JavaScript event listeners.

**Homepage** — A four-page professional developer portfolio for ParsaDev with the following pages:
- `index.html` — Home: introduction, services overview, and CS50x learning context
- `about.html` — About: background, education, and development philosophy
- `skills.html` — Skills & Services: technical skills, AI capabilities, and solution engineering
- `contact.html` — Contact: project types, contact details, and next steps

---

## ✨ Features

**Trivia:**
- `querySelectorAll('.incorrect')` selects all wrong-answer buttons; `querySelector('.correct')` selects the right one
- Click events change `style.backgroundColor` to red or green respectively
- `#check` button compares free text input against the correct answer string
- Custom CSS: blue header, hover transitions on sections, light blue button styling

**Homepage:**
- **Seven-theme colour palette** — themes defined as `[data-theme]` CSS attribute selectors setting CSS custom properties (`--bg-main`, `--accent-soft`, `--accent-strong`, `--text-dark`, `--matt-black`, `--matt-white`, `--theme-color`)
- **Theme switching** — `changeTheme()` sets `data-theme` on `<html>` and saves to `localStorage`; theme persists across pages and sessions
- **Desktop theme selector** — Bootstrap dropdown in the sticky navbar
- **Mobile theme selector** — Grid of seven coloured squares inside the hamburger menu; active theme gets a highlighted border
- **Bootstrap 5.3 grid** — Responsive two-column sections collapse to single column on mobile; three-column footer collapses gracefully
- **Sticky responsive navbar** — Hamburger toggler on smaller screens; nav links styled with theme variables
- **Intersection Observer scroll animations** — Sections fade in as they enter the viewport
- **Smooth scrolling** — Anchor links scroll with `scrollIntoView({ behavior: 'smooth' })`

---

## 🛠 Tech Stack

| Component | Detail |
|-----------|--------|
| Languages | HTML5, CSS3, JavaScript (ES6+) |
| Framework | Bootstrap 5.3 |
| Font | Ubuntu (Google Fonts) |
| Icons | Bootstrap Icons 1.11 |
| CSS approach | CSS custom properties (variables) for theming |
| JS features | `localStorage`, Intersection Observer API, event listeners |

---

## 📋 CS50x Specification Compliance

### HTML Tags Used (11 — requirement: 10+)

| Tag | Usage |
|-----|-------|
| `<nav>` | Responsive sticky navigation bar |
| `<section>` | Main content areas on each page |
| `<div>` | Layout containers and grid wrappers |
| `<img>` | Logo and section images |
| `<h1>`, `<h2>`, `<h4>` | Page headings and section titles |
| `<p>` | Body text and feedback paragraphs |
| `<a>` | Navigation links and footer links |
| `<button>` | Theme toggle, hamburger menu, trivia answers |
| `<ul>` / `<li>` | Navigation lists and footer quick links |
| `<footer>` | Site-wide footer section |
| `<i>` | Bootstrap Icons |

### CSS Properties Used (9 — requirement: 5+)

`background-color`, `color`, `font-family`, `padding`, `margin`, `border-radius`, `box-shadow`, `transition`, `transform`, `opacity`

### CSS Selectors Used (6 types — requirement: 5+)

| Selector | Example |
|----------|---------|
| Attribute selector | `[data-theme="serene-skies"]` |
| Class selector | `.navbar-custom`, `.section-box` |
| Tag selector | `h1, h2, h4` |
| Combined selector | `.theme-square[data-theme="..."]` |
| Pseudo-class | `.btn-custom:hover` |
| Descendant | `.navbar-brand img` |

### Bootstrap Features
- Responsive navbar with collapse and hamburger toggler
- Grid system (`container`, `row`, `col-lg-*`, `col-md-*`)
- Dropdown menu for theme selector
- Bootstrap Icons
- Utility classes (`d-flex`, `d-none`, `d-lg-block`, `mb-*`, `py-*`, `gap-*`)
- Order classes for mobile reflow (`order-1`, `order-2`)

### JavaScript Features
- Theme switching with CSS variable injection via `setAttribute`
- `localStorage` for theme persistence across pages and sessions
- Intersection Observer API for scroll-triggered fade-in animations
- Smooth scrolling for anchor links
- Mobile theme square click handlers with active state management

---

## 📁 File Structure
```
Homepage/
├── index.html
├── about.html
├── skills.html
├── contact.html
├── styles.css
└── Media/
    ├── Parsa Dev - Logo.png
    ├── Home Page - S1.jpg
    ├── Home Page - S2.jpg
    ├── Home Page - S3.jpg
    ├── About Page - S1.jpg
    ├── About Page - S2.jpg
    ├── About Page - S3.jpg
    ├── Skills Page - S1.jpg
    ├── Skills Page - S2.jpg
    ├── Skills Page - S3.jpg
    ├── Contact Page - S1.jpg
    ├── Contact Page - S2.jpg
    └── Contact Page - S3.jpg

Trivia/
├── index.html
└── styles.css
```

---

## ▶️ How to Run
```bash
# Navigate to either folder and start a local server
cd Homepage
http-server

# Or for Trivia
cd Trivia
http-server
```

Then open the link shown in the terminal. The site can also be opened directly by double-clicking `index.html`, though `http-server` is recommended for correct asset loading.

---

## 🎨 The Seven Themes

| Theme | Primary Colour | Character |
|-------|---------------|-----------|
| Serene Skies *(default)* | `#FFBB98` | Warm peach |
| Lavender Aroma | `#C0A9BD` | Soft mauve |
| Outdoor Yoga | `#748B6F` | Muted sage |
| Alluring Apothecary | `#E59A59` | Amber orange |
| Wellness Spa | `#BACEC1` | Pale mint |
| Vibrant Bowl | `#E0475B` | Bold coral |
| Starry Blue | `#647295` | Slate blue |

---

## 🔗 Blog & Links

The full write-up — covering how the CSS custom property theme system works, the Intersection Observer animation pattern, and what Week 8 teaches about building real interactive websites — is on the ParsaDev blog:

👉 [CS50 Week 8 HTML CSS JavaScript — Building a Trivia App and a Seven-Theme Developer Portfolio](https://www.parsadev.co.uk/post/cs50-week-8-html-css-javascript-building-a-trivia-app-and-a-seven-theme-developer-portfolio)

Browse the rest of the CS50x series at [parsadev.co.uk/blog/categories/cs50x](https://www.parsadev.co.uk/blog/categories/cs50x).

---

## 📬 Contact

Built by Parsa — find more projects and writing at [parsadev.co.uk](https://www.parsadev.co.uk).

---

## 🎓 Credit

Problem sets designed by [Harvard CS50x 2026](https://cs50.harvard.edu/x/2026/). All code written independently as part of the course.