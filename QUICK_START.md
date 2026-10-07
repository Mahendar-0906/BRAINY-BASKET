# 🚀 QUICK START — NUTRITION MODULE

## ✅ WHAT'S NEW

Your Brainy Basket now has **Personal Nutrition Tracking** as a separate tab!

### New Features:
- 👤 **Person Profiles** — Gender, Age, Height, Weight, Activity Level
- 🎯 **Nutrition Goals** — Maintain / Gain / Lose Weight
- 📊 **Daily Dashboard** — Calories, Protein, Carbs, Fat, Fiber tracking
- 📈 **Weekly Trends** — 7-day average analysis
- 🤖 **AI Insights** — Personalized recommendations
- ⏰ **Meal History** — Track Breakfast, Lunch, Dinner, Snacks
- 🔗 **Pantry Integration** — See suggestions based on available ingredients

---

## ⚡ RUN COMMANDS (3 Steps)

### Terminal 1: Start Backend
```powershell
cd "c:\Users\ADMIN\OneDrive\Desktop\brainy basket grocery version"
.\.venv\Scripts\Activate.ps1
python -m uvicorn backend.main:app --host 127.0.0.1 --port 8082 --reload
```

### Terminal 2: Start Frontend
```powershell
flutter run
```

### That's it! 🎉
App will open with Nutrition tab visible in navigation.

---

## 📱 USE IT

1. **Tap "Nutrition"** (5th tab in navigation)
2. **Select Person** — Aanya or Rohan
3. **View Nutrition** — See daily targets & progress
4. **Switch Tabs** — Daily → Weekly → Insights

---

## 📊 DEMO DATA

| Person | Age | Gender | Goal | Daily Target |
|--------|-----|--------|------|--------------|
| Aanya | 25 | Female | Maintain Weight | ~2,140 kcal |
| Rohan | 28 | Male | Gain Weight | ~3,175 kcal |

Already has **6 demo meals logged** for today!

---

## ⚠️ IMPORTANT

All nutrition values are **APPROXIMATE ESTIMATES**.
- Not medical advice
- Not a medical device
- For tracking trends only
- Consult healthcare professionals for personalized guidance

---

## 🧪 TEST IT

```powershell
# Get food database
curl http://localhost:8082/api/nutrition/foods

# Get household members
curl http://localhost:8082/api/nutrition/household/user_sih_2026

# Get today's nutrition
$today = (Get-Date).ToString("yyyy-MM-dd")
curl "http://localhost:8082/api/nutrition/daily/person001/$today"
```

---

## 📚 LEARN MORE

- **Setup & Run**: See [RUN_COMMANDS.md](RUN_COMMANDS.md)
- **Technical Details**: See [NUTRITION_MODULE.md](NUTRITION_MODULE.md)
- **Implementation**: See [NUTRITION_IMPLEMENTATION_SUMMARY.md](NUTRITION_IMPLEMENTATION_SUMMARY.md)

---

## ✨ HIGHLIGHTS

✅ Separate tab (no changes to existing features)
✅ Gender-aware calculations
✅ Goal-based calorie adjustment (±500 kcal)
✅ Mifflin-St Jeor formula (medical standard)
✅ Daily/Weekly/Insights views
✅ Demo data pre-populated
✅ All disclaimers visible
✅ Ready for production

---

**Questions?** Check the full documentation files or review code comments.

