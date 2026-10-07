# 🚀 BRAINY BASKET — v2.1 Manual Commodity Configuration
## Complete Run Commands & Setup Guide

---

## ✨ NEW FEATURES (v2.1)

**MANUAL COMMODITY CONFIGURATION:**
✅ **Empty Start** — System begins with 0 commodities
✅ **Manual Registration** — Users add each commodity explicitly
✅ **Device Validation** — Unknown devices are rejected
✅ **Master vs Live Data** — Configuration separate from sensor readings
✅ **Demo Loader** — Optional 6-item demo (non-automatic)
✅ **Clear Error Messages** — Specific validation feedback
✅ **Professional UI** — Onboarding screens for empty state

**EXISTING FEATURES (Unchanged):**
✅ **Person Profiles** — Name, Age, Gender, Height, Weight, Activity Level
✅ **Nutrition Goals** — Maintain Weight / Gain Weight / Lose Weight  
✅ **Food Consumption Tracking** — Log meals (Breakfast, Lunch, Dinner, Snacks)
✅ **Nutrition Calculation** — Automatic calculation from recipes/foods
✅ **Daily Dashboard** — Calories, Protein, Carbs, Fat, Fiber with progress bars
✅ **Weekly Trends** — 7-day averages and pattern analysis
✅ **AI Insights** — Personalized recommendations based on consumption
✅ **Meal History** — Detailed breakdown of each meal
✅ **Pantry Integration** — Connects with existing inventory
✅ **Approximate Values Disclaimer** — Clear labeling of estimates

---

---

## 🚀 **QUICK START (5 MINUTES)**

### **TL;DR - Just Run This:**

**Terminal 1 (Backend):**
```powershell
cd "c:\Users\ADMIN\OneDrive\Desktop\brainy basket grocery version"
.\.venv\Scripts\Activate.ps1
python -m uvicorn backend.main:app --host 127.0.0.1 --port 8082 --reload
```

**Terminal 2 (Frontend - open in browser):**
```powershell
# Just open in your browser:
# http://localhost:8082/
# OR:
# file:///c:/Users/ADMIN/OneDrive/Desktop/brainy%20basket%20grocery%20version/index.html
```

**That's it! App is running.**

---

## 🎯 ARCHITECTURE

```
ESP32 IoT Inventory (Commodity Tracking)
           ↓
Pantry Management (Quantity Tracking) ← Manual commodity registration
           ↓
Recipe Database (What to Cook)
           ↓
Personal Nutrition Tracking ← Separate Tab
           ↓
Daily Nutrition Dashboard
           ↓
AI Insights & Trends
```

**Tab Navigation:**
```
Dashboard → Pantry (Add commodities here) → Recipes → Shopping 
→ Assistant → IoT (Simulation) → Profile → My Nutrition
```

---

##  **DETAILED SETUP INSTRUCTIONS**

### **Step 1: Project Dependencies**

```powershell
# Navigate to project directory
cd "c:\Users\ADMIN\OneDrive\Desktop\brainy basket grocery version"

# Activate virtual environment
.\.venv\Scripts\Activate.ps1

# Install Python dependencies
pip install -r backend/requirements.txt
```

---

## 🏃 **RUN COMMANDS - CHOOSE YOUR OPTION**

### **OPTION 1: Backend Only (Recommended for Web Development)**

```powershell
# Terminal 1: Start Backend
cd "c:\Users\ADMIN\OneDrive\Desktop\brainy basket grocery version"
.\.venv\Scripts\Activate.ps1
python -m uvicorn backend.main:app --host 127.0.0.1 --port 8082 --reload
```

Then open in browser:
```
http://localhost:8082/
```

**Benefits:**
- ✅ Hot-reload enabled (`--reload`)
- ✅ See real-time backend logs
- ✅ Web app loads directly from http://localhost:8082

---

### **OPTION 2: Python Run Script**

```powershell
# Terminal 1: Start Backend + Frontend
cd "c:\Users\ADMIN\OneDrive\Desktop\brainy basket grocery version"
python run.py
```

Then open in browser: `http://localhost:8082/`

---

### **OPTION 3: Direct uvicorn Command**

```powershell
# One-liner to start backend
cd "c:\Users\ADMIN\OneDrive\Desktop\brainy basket grocery version" && .\.venv\Scripts\Activate.ps1 && python -m uvicorn backend.main:app --host 127.0.0.1 --port 8082 --reload
```

---

### **OPTION 4: Using npm (If Configured)**

```powershell
# Terminal 1: Install dependencies (first time only)
npm install

# Start backend
npm run dev
```

---

## ✅ **VERIFY IT'S RUNNING**

### **Check Backend Health:**
```powershell
curl http://localhost:8082/api/health
```

**Expected Response:**
```json
{
  "status": "ok",
  "service": "brainy-basket-backend",
  "database": "local-development"
}
```

### **Check Frontend:**
- Open browser: `http://localhost:8082/`
- Should see Brainy Basket dashboard
- On first load: empty state (no commodities yet)

### **Check API:**
```powershell
curl http://localhost:8082/api/inventory
```

---

## 🧪 **TEST COMMODITY MANAGEMENT (NEW v2.1)**

### **Once Backend is Running on http://localhost:8082**

#### **Test 1: Create a Commodity (Manual Registration)**
```powershell
$body = @{
    name = "Toor Dal"
    category = "Pulses"
    minimumQuantity = 1.0
    unit = "kg"
    storageLocation = "Container C"
    deviceId = "ESP32_003"
    rfidTagId = "RFID003"
    rfTagId = "RF003"
} | ConvertTo-Json

curl -X POST "http://localhost:8082/api/commodities" `
  -H "Content-Type: application/json" `
  -d $body
```

**Expected Response:**
```json
{
  "success": true,
  "commodity": {
    "id": "PULSE_...",
    "itemId": "PULSE_...",
    "name": "Toor Dal",
    "category": "Pulses",
    "minimumQuantity": 1.0,
    "unit": "kg",
    "currentQuantity": 0.0,
    "status": "OUT_OF_STOCK",
    "storageLocation": "Container C",
    "deviceId": "ESP32_003",
    "createdAt": "2026-09-01T..."
  }
}
```

#### **Test 2: List All Commodities**
```powershell
curl "http://localhost:8082/api/commodities"
```

**Expected Response:** Array of all registered commodities

#### **Test 3: Load Demo Commodities (Optional)**
```powershell
curl -X POST "http://localhost:8082/api/demo/load-sample-commodities"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Demo commodities loaded",
  "loaded": 6,
  "commodities": [...]
}
```

Loads 6 items:
- Rice (ESP32_001)
- Wheat (ESP32_002)
- Toor Dal (ESP32_003)
- Moong Dal (ESP32_004)
- Ragi (ESP32_005)
- Chickpeas (ESP32_006)

#### **Test 4: Map Hardware to Commodity**
```powershell
$body = @{
    deviceId = "ESP32_003"
    rfidTagId = "RFID003"
    rfTagId = "RF003"
} | ConvertTo-Json

curl -X POST "http://localhost:8082/api/commodities/PULSE001/map-device" `
  -H "Content-Type: application/json" `
  -d $body
```

#### **Test 5: Send Sensor Data (Correct Device)**
```powershell
$body = @{
    deviceId = "ESP32_003"
    itemId = "PULSE001"
    sensorType = "weight"
    value = 2.35
    unit = "kg"
} | ConvertTo-Json

curl -X POST "http://localhost:8082/api/iot/sensor" `
  -H "Content-Type: application/json" `
  -d $body
```

**Expected Response (200):**
```json
{
  "success": true,
  "itemId": "PULSE001",
  "quantity": 2.35,
  "status": "AVAILABLE",
  "previousQuantity": 0.0,
  "changeKg": 2.35
}
```

#### **Test 6: Send Sensor Data (Unknown Device - Should FAIL)**
```powershell
$body = @{
    deviceId = "ESP32_UNKNOWN"
    itemId = "PULSE001"
    value = 2.35
    unit = "kg"
} | ConvertTo-Json

curl -X POST "http://localhost:8082/api/iot/sensor" `
  -H "Content-Type: application/json" `
  -d $body
```

**Expected Response (422):**
```json
{
  "detail": "Device ESP32_UNKNOWN is not registered for commodity Toor Dal. Please register and map the device first."
}
```

#### **Test 7: Update Commodity**
```powershell
$body = @{
    minimumQuantity = 1.5
    storageLocation = "Container D"
} | ConvertTo-Json

curl -X PUT "http://localhost:8082/api/commodities/PULSE001" `
  -H "Content-Type: application/json" `
  -d $body
```

#### **Test 8: Delete Commodity**
```powershell
curl -X DELETE "http://localhost:8082/api/commodities/PULSE001"
```

---

## 🧪 **TEST NUTRITION FEATURES**

###  **Once Backend is Running**

#### **Test 1: Get All Food Items**
```powershell
curl http://localhost:8082/api/nutrition/foods
```

Expected output: ~15 foods with nutrition values

#### **Test 2: Get Household Members**
```powershell
curl http://localhost:8082/api/nutrition/household/user_sih_2026
```

Expected output:
```json
{
  "members": [
    {
      "personId": "person001",
      "name": "Aanya",
      "age": 25,
      "gender": "Female",
      "height": 165,
      "weight": 62.0,
      "activityLevel": "moderate",
      "nutritionGoal": "maintainWeight"
    },
    {
      "personId": "person002",
      "name": "Rohan",
      "age": 28,
      "gender": "Male",
      "height": 180,
      "weight": 75.0,
      "activityLevel": "active",
      "nutritionGoal": "gainWeight"
    }
  ]
}
```

#### **Test 3: Get Daily Nutrition (Today)**
```powershell
$today = (Get-Date).ToString("yyyy-MM-dd")
curl "http://localhost:8082/api/nutrition/daily/person001/$today"
```

#### **Test 4: Log a Meal**
```powershell
$body = @{
    mealType = "Lunch"
    date = "2026-08-30"
    ingredients = @(
        @{
            foodId = "GRAIN_RICE"
            quantity = 150
            unit = "g"
        },
        @{
            foodId = "PULSE_TOOR_DAL"
            quantity = 80
            unit = "g"
        }
    )
    notes = "Rice with Toor Dal"
} | ConvertTo-Json

curl -X POST "http://localhost:8082/api/nutrition/meal-logs/person001" `
  -H "Content-Type: application/json" `
  -d $body
```

---

## 📊 **DEMO DATA INCLUDED**

### **Pre-populated Household Members**

1. **Aanya** (Female, 25y, 165cm, 62kg)
   - Activity: Moderate
   - Goal: Maintain Weight
   - Daily Target: ~1,900 kcal

2. **Rohan** (Male, 28y, 180cm, 75kg)
   - Activity: Active
   - Goal: Gain Weight
   - Daily Target: ~2,400 kcal

### **Sample Foods (15 items)**

| Category | Foods |
|----------|-------|
| Pulses | Toor Dal, Moong Dal, Chickpeas |
| Grains | Rice, Wheat Flour, Ragi |
| Vegetables | Tomato, Onion, Potato |
| Dairy | Milk, Eggs |
| Nuts/Seeds | Peanuts |

### **Demo Meals (Pre-logged for Today)**

**Aanya's meals:**
- Breakfast: Ragi Dosa (~250 kcal)
- Lunch: Rice + Toor Dal (~600 kcal)
- Dinner: Moong Dal Khichdi (~320 kcal)

**Rohan's meals:**
- Breakfast: Eggs (3 pcs) (~230 kcal)
- Lunch: Chickpea Curry + Rice (~750 kcal)
- Dinner: Wheat Roti + Peanuts (~380 kcal)

---

## 🎨 **UI/UX FEATURES**

### **Nutrition Tab** (New Separate Tab)

#### **Daily Tab:**
- Person selector (switch between household members)
- Nutrition goal display (Maintain/Gain/Lose Weight)
- Progress cards for each nutrient
- Visual progress bars (0-150%)
- Meal breakdown with icons
- Date picker for historical data

#### **Weekly Tab:**
- 7-day average nutrition
- Trend indicators (↑ Above / ✓ On-track / ↓ Below)
- Consistency analysis

#### **Insights Tab:**
- AI-generated nutrition insights
- Protein intake analysis
- Carbohydrate recommendations
- Fiber intake guidance
- Quick tips linked to pantry

---

## ⚠️ **IMPORTANT DISCLAIMERS**

```
⚠️  APPROXIMATE NUTRITIONAL VALUES
All nutrition calculations are ESTIMATES based on standardized food data.
These values are NOT medically verified.

❌  NOT A MEDICAL DEVICE
This system does NOT provide medical diagnosis or treatment.
Do NOT use for clinical nutrition therapy.

⚠️  CONSULT PROFESSIONALS
Always consult healthcare professionals for personalized nutrition advice.

❓  TARGETS ARE SUGGESTIONS
Recommended nutrition targets use standard formulas.
Individual needs vary based on health conditions.
```

---

## 🔄 **WORKFLOW: USER PERSPECTIVE**

```
1. Open "Nutrition" Tab (New)
   ↓
2. Select Person (Aanya / Rohan / etc)
   ↓
3. View Daily Summary
   - See calories, protein, carbs, fat, fiber
   - Compare against personalized targets
   - See meal breakdown by type
   ↓
4. Switch to Weekly Tab
   - View 7-day trends
   - Identify eating patterns
   ↓
5. Check Insights Tab
   - Get AI recommendations
   - See pantry suggestions
   - Get protein/fiber tips
```

---

## 📁 **FILE STRUCTURE**

```
lib/
├── models.dart                      ← HouseholdMember, FoodItem, MealLog, NutrientInfo
├── state.dart                       ← Nutrition state management + helpers
├── main.dart                        ← Updated navigation (8 tabs now)
└── screen_nutrition.dart            ← NEW NUTRITION TAB UI

backend/
├── main.py                          ← Updated with nutrition API routes
├── nutrition_service.py             ← NEW backend service
├── firebase_service.py              ← Updated collections
└── requirements.txt
```

---

## 🔧 **TROUBLESHOOTING**

### **Backend won't start**

```powershell
# Check if port 8082 is in use
netstat -ano | findstr :8082

# If in use, kill the process or use different port
python -m uvicorn backend.main:app --host 127.0.0.1 --port 8083 --reload
```

### **Flutter won't connect to backend**

```powershell
# Ensure backend is running first
# Check backend is accessible
curl http://localhost:8082/health

# If using Android emulator, use special IP
# Replace localhost with 10.0.2.2 in code
```

### **Demo data not showing**

```powershell
# Ensure state.dart initialization completed
# Check: AppState constructor calls _initializeDemoNutrition()
# Restart app with: flutter run
```

### **Nutrition values seem wrong**

```
✓ Values are ESTIMATES (not measured)
✓ Based on 100g serving sizes (standardized)
✓ Actual values depend on food prep/quality
✓ Use for tracking trends, not exact measurements
```

---

## 🎯 **NEXT FEATURES TO ADD**

1. **Barcode Scanner** — Quick food logging
2. **Meal Plan Generator** — Auto-suggest meals for targets
3. **Real USDA Database** — Replace estimates with verified data
4. **Shopping Optimization** — Add nutrients to shopping list
5. **Wearable Integration** — Connect with fitness trackers
6. **Allergen Warnings** — Track and alert on allergens
7. **PDF Reports** — Export weekly/monthly summaries
8. **Macro Cycling** — Advanced nutrition strategies

---

## 📞 **SUPPORT**

**For issues or questions:**

1. Check `NUTRITION_MODULE.md` for detailed technical docs
2. Verify backend is running: `curl http://localhost:8082/health`
3. Review demo data in `state.dart` (demo meals)
4. Check `nutrition_service.py` for calculation logic

---

## ✅ **VERIFICATION CHECKLIST**

Before deployment, verify:

- [ ] Backend starts without errors
- [ ] Flutter app loads without crashes
- [ ] Nutrition tab appears in navigation (8th tab total)
- [ ] Can switch between Aanya and Rohan
- [ ] Daily nutrition shows demo meals
- [ ] Nutrient progress bars update correctly
- [ ] Weekly tab shows averages
- [ ] Insights tab shows recommendations
- [ ] All disclaimers visible
- [ ] Existing features still work (Pantry, Recipes, Shopping, etc.)

---

**Status:** ✅ **READY FOR DEPLOYMENT**

**Created:** 2026-08-30  
**Version:** 1.0.0  
**Module:** Personal Nutrition Tracking

