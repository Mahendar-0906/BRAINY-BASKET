# ⚡ BRAINY BASKET — QUICK COMMANDS REFERENCE

## 🚀 START APPLICATION (30 seconds)

```powershell
# Terminal 1: Start Backend
cd "c:\Users\ADMIN\OneDrive\Desktop\brainy basket grocery version"
.\.venv\Scripts\Activate.ps1
python -m uvicorn backend.main:app --host 127.0.0.1 --port 8082 --reload
```

Then open browser: **`http://localhost:8082/`**

---

## ✅ VERIFY RUNNING

```powershell
# Check health
curl http://localhost:8082/api/health

# Check inventory
curl http://localhost:8082/api/inventory

# Check commodities
curl http://localhost:8082/api/commodities
```

---

## 📦 COMMODITY COMMANDS

### Create Commodity
```powershell
$body = @{
    name = "Toor Dal"
    category = "Pulses"
    minimumQuantity = 1.0
    unit = "kg"
} | ConvertTo-Json

curl -X POST "http://localhost:8082/api/commodities" `
  -H "Content-Type: application/json" `
  -d $body
```

### List Commodities
```powershell
curl http://localhost:8082/api/commodities
```

### Load Demo Data (6 items)
```powershell
curl -X POST "http://localhost:8082/api/demo/load-sample-commodities"
```

### Send Sensor Reading
```powershell
$body = @{
    deviceId = "ESP32_003"
    itemId = "PULSE001"
    value = 2.35
    unit = "kg"
} | ConvertTo-Json

curl -X POST "http://localhost:8082/api/iot/sensor" `
  -H "Content-Type: application/json" `
  -d $body
```

### Update Commodity
```powershell
$body = @{
    minimumQuantity = 1.5
    storageLocation = "Container D"
} | ConvertTo-Json

curl -X PUT "http://localhost:8082/api/commodities/PULSE001" `
  -H "Content-Type: application/json" `
  -d $body
```

### Delete Commodity
```powershell
curl -X DELETE "http://localhost:8082/api/commodities/PULSE001"
```

---

## 🥗 NUTRITION COMMANDS

### Get All Foods
```powershell
curl http://localhost:8082/api/nutrition/foods
```

### Get Household Members
```powershell
curl http://localhost:8082/api/nutrition/household/user_sih_2026
```

### Log a Meal
```powershell
$body = @{
    mealType = "Lunch"
    date = "2026-09-01"
    ingredients = @(
        @{
            foodId = "GRAIN_RICE"
            quantity = 150
            unit = "g"
        }
    )
} | ConvertTo-Json

curl -X POST "http://localhost:8082/api/nutrition/meal-logs/person001" `
  -H "Content-Type: application/json" `
  -d $body
```

### Get Daily Nutrition
```powershell
curl "http://localhost:8082/api/nutrition/daily/person001/2026-09-01"
```

### Get Weekly Nutrition
```powershell
curl "http://localhost:8082/api/nutrition/weekly/person001/2026-09-01"
```

---

## 🎮 FRONTEND ACTIONS

**Dashboard:**
- Shows overview, IoT status, alerts

**Pantry (+ Add Commodity):**
- Click to manually register commodities
- Or click "📦 Load demo commodities" for testing

**IoT Monitor:**
- Simulation buttons to test sensor flow

**My Nutrition:**
- Track personal nutrition
- View trends and insights

---

## 📝 ENVIRONMENT SETUP (First Time Only)

```powershell
# Navigate to project
cd "c:\Users\ADMIN\OneDrive\Desktop\brainy basket grocery version"

# Activate virtual environment
.\.venv\Scripts\Activate.ps1

# Install dependencies
pip install -r backend/requirements.txt
```

---

## 🔧 TROUBLESHOOTING

**Backend won't start?**
```powershell
# Check if port 8082 is in use
netstat -ano | findstr :8082

# Kill process if needed (replace PID)
taskkill /PID 12345 /F
```

**Clear data?**
```powershell
# Delete local database
del ".\.brainy_basket_data.json"
```

**Reinstall dependencies?**
```powershell
pip install --upgrade -r backend/requirements.txt
```

---

## 📚 DOCUMENTATION

- **Full Guide:** `MANUAL_COMMODITY_CONFIGURATION_GUIDE.md`
- **Quick Start:** `MANUAL_COMMODITY_QUICK_START.md`
- **Implementation Report:** `IMPLEMENTATION_REPORT_v2.1.md`
- **Complete Commands:** `RUN_COMMANDS.md`

---

**Version:** 2.1 | **Status:** ✅ Ready to run
