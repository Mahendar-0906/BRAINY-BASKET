# Brainy Basket 🧺

**Smart Pantry & Grocery Management + Personal Nutrition Tracking** — an IoT-powered inventory tracker with AI recipe suggestions and personal nutrition dashboards, built with a **zero-dependency web app** (`index.html` + `app.js` + `styles.css`), plus **Python FastAPI** backend, **Flutter** app, and **ESP32** firmware.

---

## 📌 Overview

### Core system (unchanged concept)

```
ESP32 (weights) → Firebase → Inventory → AI Recipes → Shopping List
```

### Additive layer: Personal Nutrition Tracking

```
Food Consumed → Person Profile → Nutrition Calculation → Daily Intake → AI Nutrition Insight
```

The nutrition module reuses the **same pantry commodities and recipes** — no separate food database.

---

## ✨ Features

### Core
- **Dashboard** — pantry stats, low-stock alerts, AI recipe suggestions, IoT status
- **Pantry** — CRUD for commodities, thresholds, quick adjust buttons
- **AI Recipes** — recipes matched to pantry with % readiness + approximate per-serving nutrition
- **Smart Shopping List** — auto-generated from low stock + manual items
- **IoT Monitor** — ESP32 device status + full simulation suite

### 🥗 My Nutrition (new)
- **Person profiles** — Name, Age, Gender, Height, Weight, Activity Level, Nutrition Goal (Maintain / Gain / Lose). Multiple profiles per household (Person 1, Person 2, …).
- **Food consumption logging** — Breakfast / Lunch / Dinner / Snacks, quantity, date. Foods come from the **recipe engine** or **pantry commodities**.
- **Nutrition calculation** — Calories, Protein, Carbohydrates, Fat, Fiber (approximate per-100g estimates, scaled by serving size).
- **Daily dashboard** — calorie ring + progress bars: `Protein 62 / 80 g`, etc. Targets are **stored per person** (Mifflin-St Jeor), never hard-coded globally.
- **Meal history** — grouped by meal with per-food nutrition breakdown.
- **Daily / Weekly / Monthly summaries** — averages vs targets, plus **trend charts** (calorie, protein, fiber, carbohydrate).
- **AI nutrition insights** — rule-based suggestions referencing your pantry ("protein below target → consider Toor Dal, Moong Dal — already in your pantry").
- **Accuracy rule** — everything is labelled **"Approximate nutritional values"**. Not a medical or clinical tool; no diagnosis or treatment advice.

---

## 🚀 Quick Start (Web App — no build step)

```bash
# simply open index.html in any modern browser
start index.html        # Windows
# or: python -m http.server 8000  → http://localhost:8000
```

## 🐍 Backend (optional)

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

API docs: http://localhost:8000/docs

## 📱 Flutter app

```bash
flutter pub get
flutter run -d chrome
```

---

## 🗂 Project Structure

```
brainy_basket/
├── index.html         # Web app shell (sidebar layout + modals)
├── styles.css         # Complete redesign styles
├── app.js             # All logic: core + nutrition module
├── backend/           # FastAPI: inventory, recipes, nutrition endpoints
├── lib/               # Flutter app (screens incl. nutrition screens)
└── esp32/main.ino     # ESP32 firmware
```

---

## 📡 Backend API (nutrition highlights)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/POST | `/api/nutrition/profiles` | Person profiles (per-person targets) |
| POST/DELETE | `/api/nutrition/logs` | Meal consumption logs |
| GET | `/api/nutrition/daily/{profile_id}` | Daily intake vs targets |
| GET | `/api/nutrition/summary/{profile_id}?days=7` | D/W/M summaries |
| GET | `/api/nutrition/trends/{profile_id}?days=14` | Trend series |
| POST | `/api/nutrition/insights/{profile_id}` | AI insights (pantry-aware) |
| GET | `/api/recipes/{id}/nutrition` | Approx per-serving recipe nutrition |

---

## ⚠️ Accuracy Rule

Nutrition values are **estimates** from public food-composition data (IFCT-style). Brainy Basket is **not** a medical or clinical nutrition tool and does not provide medical diagnosis or treatment recommendations.

---

## 📄 License

MIT