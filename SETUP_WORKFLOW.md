# 📊 BRAINY BASKET — SETUP & RUN WORKFLOW

## 🎯 COMPLETE WORKFLOW

```
┌─────────────────────────────────────────────────────────────┐
│ 1. SETUP (First Time Only)                                  │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  $ cd c:\Users\ADMIN\OneDrive\Desktop\brainy basket...      │
│  $ .\.venv\Scripts\Activate.ps1                              │
│  $ pip install -r backend/requirements.txt                   │
│                                                               │
│  (Wait 1-2 minutes for dependencies to install)              │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. START BACKEND (Every Session)                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Terminal 1:                                                  │
│  $ cd c:\Users\ADMIN\OneDrive\Desktop\brainy basket...      │
│  $ .\.venv\Scripts\Activate.ps1                              │
│  $ python -m uvicorn backend.main:app \                      │
│    --host 127.0.0.1 --port 8082 --reload                    │
│                                                               │
│  ⏱️ Wait for: "Uvicorn running on http://127.0.0.1:8082"   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. VERIFY RUNNING                                           │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Terminal 2:                                                  │
│  $ curl http://localhost:8082/api/health                    │
│                                                               │
│  ✅ Should return: {"status":"ok",...}                      │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. OPEN FRONTEND                                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Browser:                                                     │
│  → http://localhost:8082/                                    │
│                                                               │
│  ✅ Should see: Brainy Basket Dashboard (empty state)       │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. ADD YOUR FIRST COMMODITY                                 │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  UI Method:                                                   │
│  → Pantry tab                                                │
│  → Click "+ Add commodity"                                   │
│  → Enter name: "Toor Dal"                                    │
│  → Enter category: "Pulses"                                  │
│  → Enter min: 1.0                                            │
│  → Click "Register commodity"                                │
│                                                               │
│  OR                                                           │
│                                                               │
│  API Method:                                                  │
│  $ curl -X POST http://localhost:8082/api/commodities \     │
│    -H "Content-Type: application/json" \                    │
│    -d '{"name":"Toor Dal","category":"Pulses",...}'         │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. SEND SENSOR DATA (Simulate ESP32)                       │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  $ curl -X POST http://localhost:8082/api/iot/sensor \     │
│    -H "Content-Type: application/json" \                    │
│    -d '{                                                     │
│      "deviceId": "ESP32_003",                                │
│      "itemId": "PULSE_...",                                  │
│      "value": 2.35,                                          │
│      "unit": "kg"                                            │
│    }'                                                        │
│                                                               │
│  ✅ Response: {"success":true, "quantity":2.35,...}         │
│  ✅ Dashboard updates in real-time!                         │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
                    🎉 YOU'RE DONE!
```

---

## 📋 COMMAND REFERENCE TABLE

| Step | What to Do | Command |
|------|-----------|---------|
| 1️⃣ | Navigate to project | `cd "c:\Users\ADMIN\OneDrive\Desktop\brainy basket grocery version"` |
| 2️⃣ | Activate Python env | `.\.venv\Scripts\Activate.ps1` |
| 3️⃣ | Install deps (1st time) | `pip install -r backend/requirements.txt` |
| 4️⃣ | Start backend | `python -m uvicorn backend.main:app --host 127.0.0.1 --port 8082 --reload` |
| 5️⃣ | Test health | `curl http://localhost:8082/api/health` |
| 6️⃣ | Open app | Browser: `http://localhost:8082/` |
| 7️⃣ | Load demo data | `curl -X POST http://localhost:8082/api/demo/load-sample-commodities` |
| 8️⃣ | Add commodity | UI: Pantry → + Add commodity |
| 9️⃣ | Send sensor | `curl -X POST http://localhost:8082/api/iot/sensor ...` |

---

## 🎮 USER WORKFLOW

### For Testing (Quick)

```
Open app → Pantry → "📦 Load demo commodities" → 6 items appear
                ↓
        IoT tab → Click "Simulate sensor" → Quantity updates
                ↓
        Dashboard updates in real-time ✅
```

### For Production (Real)

```
Open app → Pantry → "+ Add commodity" → Enter your items
                ↓
        Map ESP32 device to commodity
                ↓
        Physical sensor measures
                ↓
        ESP32 sends data → Backend validates → Quantity updates
                ↓
        Dashboard reflects real state ✅
```

---

## 🔍 API FLOW

```
┌─────────────────┐
│  User/Hardware  │
└────────┬────────┘
         │
         ↓ POST /api/iot/sensor
┌──────────────────────────────────┐
│  Backend Validation              │
│  1. Commodity exists?            │
│  2. Device mapped?               │
│  3. Value valid?                 │
└────────┬─────────────────────────┘
         │
         ├─ YES ──→ Firebase update
         │          ↓
         │         Activity log
         │          ↓
         │         Alert check
         │          ↓
         │         Dashboard listener
         │          ↓
         │         UI refreshes ✅
         │
         └─ NO ──→ HTTP 422 Error
                   ↓
                Clear error message
```

---

## 📊 DATA FLOW

```
MASTER DATA (Configuration)          LIVE DATA (Sensor-Driven)
       ↓                                    ↑
┌──────────────────┐                ┌─────────────────┐
│  Commodity:      │                │  Quantity:      │
│  - Name          │ Manual         │  - Current      │ Auto
│  - Category      │ Config         │  - Status       │ Updated
│  - Min Qty       │                │  - Last Reading │
│  - Device ID     │                │                 │
│  - Storage Loc   │                └────────┬────────┘
│  - RFID/RF Tags  │                         │
└──────────────────┘                         │
                                    ESP32 sends reading
                                             │
                                    Firebase receives
                                             │
                                    Dashboard listens
                                             ↓
                                         UI updates
```

---

## 🚨 COMMON ISSUES & FIXES

### Issue: "Port 8082 already in use"
**Fix:**
```powershell
# Find process using port
netstat -ano | findstr :8082

# Kill it (replace 12345 with PID)
taskkill /PID 12345 /F

# Then restart backend
```

### Issue: "ModuleNotFoundError: No module named 'fastapi'"
**Fix:**
```powershell
# Reinstall dependencies
pip install --upgrade -r backend/requirements.txt
```

### Issue: "App shows empty but should have commodities"
**Fix:**
```powershell
# Delete local database
del ".\.brainy_basket_data.json"

# Refresh browser (Ctrl+Shift+R)
```

### Issue: "Sensor data not updating"
**Check:**
1. Backend running? `curl http://localhost:8082/api/health`
2. Commodity registered? `curl http://localhost:8082/api/commodities`
3. Device mapped? Check commodity has `deviceId`
4. Correct IDs in sensor payload? `deviceId` and `itemId` must match

---

## 📱 QUICK TIPS

- 💡 Use `--reload` flag to auto-restart backend on code changes
- 💡 Open `http://localhost:8082/docs` for Swagger API docs
- 💡 Check Terminal 1 logs to see what backend is doing
- 💡 Use Ctrl+Shift+R in browser to hard-refresh frontend
- 💡 Commodity registration is manual (no auto-generation)
- 💡 Load demo data first to see the system working

---

## 📖 RELATED DOCUMENTATION

| Document | Purpose |
|----------|---------|
| `QUICK_COMMANDS.md` | Fast copy-paste commands |
| `RUN_COMMANDS.md` | Complete run guide |
| `MANUAL_COMMODITY_CONFIGURATION_GUIDE.md` | Full API reference |
| `IMPLEMENTATION_REPORT_v2.1.md` | Technical details |

---

**Ready to start?** Copy the command from Step 2 above! 🚀
