# BRAINY BASKET — MANUAL COMMODITY DATA CONFIGURATION
## Implementation Summary

**Date:** September 1, 2026  
**Version:** 2.1.0  
**Core Principle:** *All commodity master data must be MANUALLY CONFIGURED. The system starts empty and never auto-generates inventory.*

---

## WHAT CHANGED

### Before (Automatic Seed Data — ❌ REMOVED)
- The app auto-loaded 12 hardcoded commodities on startup
- Backend automatically seeded inventory on first run
- Unknown devices could potentially cause issues
- Dashboard showed data that wasn't actually in the system
- Violated the principle of "IoT system is the source of truth"

### After (Manual Configuration — ✅ NEW)
- The app starts with **ZERO commodities**
- Users must explicitly add each commodity
- Backend rejects unknown devices with clear error messages
- Dashboard shows empty state with onboarding guidance
- Master data (commodity definition) is separate from live data (quantity/status)
- Hardware mapping is explicit and validated

---

## SYSTEM ARCHITECTURE

```
┌─────────────────────────────────────────┐
│  USER / ADMINISTRATOR                   │
│  - Manually registers commodities       │
│  - Manually maps hardware                │
│  - Sees real-time dashboard              │
└──────────────┬──────────────────────────┘
               │
        COMMODITY MASTER DATA
               │
        ┌──────┴──────────┐
        │                 │
    Name, Category,    RFID, RF,
    Min Qty, Unit,     ESP32 Device
    Storage Loc        (Hardware mapping)
        │                 │
        └──────┬──────────┘
               │
        ┌──────▼──────────────┐
        │ Backend Validation   │
        │ - Device registered? │
        │ - Commodity exists?  │
        │ - Is device mapped?  │
        └──────┬──────────────┘
               │
        ┌──────▼──────────────┐
        │ PHYSICAL PANTRY      │
        │ - Weight sensors     │
        │ - RFID readers       │
        │ - RF tags            │
        └──────┬──────────────┘
               │
        ┌──────▼──────────────┐
        │ ESP32 Transmits:     │
        │ {deviceId, value}    │
        └──────┬──────────────┘
               │
        ┌──────▼──────────────────────┐
        │ Python Backend               │
        │ POST /api/iot/sensor         │
        │ - Validates device           │
        │ - Finds mapped commodity     │
        │ - Rejects unknown devices    │
        └──────┬──────────────────────┘
               │
        ┌──────▼──────────────────┐
        │ Firebase Database        │
        │ LIVE INVENTORY STATE:    │
        │ - currentQuantity        │
        │ - status (LOW/OUT/OK)    │
        │ - lastUpdated            │
        └──────┬──────────────────┘
               │
        ┌──────▼──────────────────┐
        │ Dashboard                │
        │ Real-time listener       │
        │ Updates automatically    │
        └──────────────────────────┘
```

---

## KEY FEATURES

### 1. EMPTY START
- Application starts with ZERO commodities
- No fake data or demo items auto-loaded
- Users see clear onboarding screens

### 2. MANUAL COMMODITY REGISTRATION
**Create a commodity via:**
- **UI:** Pantry → + Add Commodity
- **API:** `POST /api/commodities`

**Required fields:**
```json
{
  "name": "Toor Dal",
  "category": "Pulses",
  "minimumQuantity": 1.0,
  "unit": "kg",
  "storageLocation": "Container C",
  "rfidTagId": "RFID003",       // optional
  "rfTagId": "RF003",           // optional
  "deviceId": "ESP32_003"        // optional
}
```

**Initial state:**
- `currentQuantity`: 0
- `status`: "OUT_OF_STOCK"
- Cannot be created by unknown devices

### 3. SEPARATE MASTER VS LIVE DATA
**MASTER DATA (Configuration):**
```
itemId, name, category, minimumQuantity
unit, storageLocation, rfidTagId, rfTagId
deviceId, createdAt
```
Modified only by: `PUT /api/commodities/{id}`

**LIVE DATA (Sensor-driven):**
```
currentQuantity, status
lastUpdated, lastSensorValue
```
Modified only by: Validated ESP32 sensor readings

### 4. STRICT DEVICE VALIDATION
**Unknown device sends data:**
```
{
  "deviceId": "ESP32_UNKNOWN",
  "itemId": "PULSE001",
  "value": 2.5
}
```
**Response:**
```json
{
  "error": "Unknown commodity itemId: PULSE001. Commodity must be manually registered first.",
  "statusCode": 422
}
```

**Or if device not mapped:**
```
{
  "error": "Device ESP32_004 is not registered for commodity Toor Dal. Please register and map the device first.",
  "statusCode": 422
}
```

### 5. DEMO DATA LOADER (Non-automatic)
**Option 1: UI Button**
- Dashboard/Pantry screen → "📦 Load demo commodities"
- Loads 6 sample items for testing
- User can edit/delete anytime

**Option 2: API Endpoint**
```bash
POST /api/demo/load-sample-commodities
```

**Demo commodities (for testing only):**
- Rice (Grains, 2.0 kg min, ESP32_001)
- Wheat (Grains, 2.0 kg min, ESP32_002)
- Toor Dal (Pulses, 1.0 kg min, ESP32_003)
- Moong Dal (Pulses, 1.0 kg min, ESP32_004)
- Ragi (Millets, 0.75 kg min, ESP32_005)
- Chickpeas (Beans/Legumes, 0.75 kg min, ESP32_006)

---

## API ENDPOINTS

### Commodity Management

#### Create Commodity
```
POST /api/commodities
Content-Type: application/json

{
  "name": "Toor Dal",
  "category": "Pulses",
  "minimumQuantity": 1.0,
  "unit": "kg",
  "storageLocation": "Container C",
  "rfidTagId": "RFID003",
  "rfTagId": "RF003",
  "deviceId": "ESP32_003"
}

Response 200:
{
  "success": true,
  "commodity": {
    "id": "PULSE_..." ,
    "itemId": "PULSE_...",
    "name": "Toor Dal",
    "category": "Pulses",
    "minimumQuantity": 1.0,
    "unit": "kg",
    "currentQuantity": 0.0,
    "status": "OUT_OF_STOCK",
    "storageLocation": "Container C",
    "rfidTagId": "RFID003",
    "rfTagId": "RF003",
    "deviceId": "ESP32_003",
    "createdAt": "2026-09-01T...",
    "lastUpdated": "2026-09-01T..."
  }
}
```

#### List All Commodities
```
GET /api/commodities

Response 200:
{
  "commodities": [...],
  "total": 6,
  "principle": "All commodities are manually registered..."
}
```

#### Get Single Commodity
```
GET /api/commodities/{commodity_id}
```

#### Update Commodity
```
PUT /api/commodities/{commodity_id}
Content-Type: application/json

{
  "name": "Toor Dal Premium",
  "minimumQuantity": 1.5,
  "deviceId": "ESP32_004"
}
```

#### Delete Commodity
```
DELETE /api/commodities/{commodity_id}
```

#### Map Hardware to Commodity
```
POST /api/commodities/{commodity_id}/map-device

{
  "deviceId": "ESP32_003",
  "rfidTagId": "RFID003",
  "rfTagId": "RF003"
}
```

#### Load Demo Data
```
POST /api/demo/load-sample-commodities

Response 200:
{
  "success": true,
  "message": "Demo commodities loaded",
  "loaded": 6,
  "commodities": [...]
}
```

### Existing Inventory Endpoints (Modified)

#### Get Inventory
```
GET /api/inventory

Response 200:
{
  "inventory": [...],
  "database": "firebase" or "local-development",
  "principle": "Displays only manually registered commodities..."
}
```

#### Receive Sensor Reading (Unchanged but now validates devices)
```
POST /api/iot/sensor

{
  "deviceId": "ESP32_003",
  "itemId": "PULSE001",
  "sensorType": "weight",
  "value": 2.35,
  "unit": "kg"
}

Response 200:
{
  "success": true,
  "itemId": "PULSE001",
  "quantity": 2.35,
  "status": "AVAILABLE",
  "previousQuantity": 2.50,
  "changeKg": -0.15
}

Response 422:
{
  "error": "Device ESP32_999 is not registered for commodity..."
}
```

---

## USER WORKFLOWS

### Workflow 1: Add Your First Commodity (Manual)

**Step 1: Go to Pantry**
- Click "Pantry" in navigation
- See empty state with onboarding

**Step 2: Register Commodity**
- Click "+ Add Commodity"
- Fill in required fields:
  - Name: "Toor Dal"
  - Category: "Pulses"
  - Minimum: 1.0
  - Unit: "kg"
  - Storage: "Container C"
- Optionally add:
  - ESP32 Device ID: "ESP32_003"
  - RFID Tag: "RFID003"
  - RF Tag: "RF003"
- Click "Register Commodity"

**Step 3: Verify**
- Commodity appears in pantry table with:
  - Quantity: 0 (always starts empty)
  - Status: OUT_OF_STOCK
  - Last Updated: now

**Step 4: Hardware sends data**
- Physical sensor measures: 2.35 kg
- ESP32 sends to backend
- Backend validates device is mapped
- Firebase updates Toor Dal → 2.35 kg
- Dashboard updates automatically

### Workflow 2: Load Demo Data (Testing)

**Option A: From UI**
- Go to Pantry (empty state)
- Click "📦 Load demo commodities"
- 6 sample items appear

**Option B: From API**
```bash
curl -X POST http://localhost:8000/api/demo/load-sample-commodities
```

**Result:**
- 6 commodities added
- Can be edited or deleted anytime
- Quantity starts at 0 for all

### Workflow 3: Map Hardware to Existing Commodity

**If you created a commodity without hardware:**

**API Method:**
```bash
curl -X POST http://localhost:8000/api/commodities/PULSE001/map-device \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "ESP32_003",
    "rfidTagId": "RFID003",
    "rfTagId": "RF003"
  }'
```

**UI Method:**
- Edit the commodity (future: add edit modal)
- Update device ID fields
- Save

---

## BACKEND IMPLEMENTATION DETAILS

### New Files
- **`backend/commodity_service.py`** — Commodity CRUD operations and device mapping validation

### Modified Files
- **`backend/inventory_service.py`** — Removed auto-seeding, added strict device validation
- **`backend/main.py`** — Added commodity management endpoints, demo loader
- **`backend/firebase_service.py`** — No changes (works as-is)

### Key Validation Rules

1. **Commodity Creation**
   - Name required, non-empty
   - Category required, non-empty
   - Minimum quantity ≥ 0
   - Unit must be one of: kg, g, L, ml, piece, dozen

2. **Sensor Reading Processing**
   - Commodity must exist (registered)
   - Device must be mapped to commodity
   - If device has no mapping → reject
   - Only weight sensors accepted
   - Value range: 0-10000
   - Unit must be kg or g

3. **Device Validation**
   - Unknown devices CANNOT create commodities
   - Unknown devices CANNOT create inventory items
   - Unknown devices get clear error message
   - Device status tracked in iot_devices collection

---

## FRONTEND IMPLEMENTATION DETAILS

### Modified `app.js`

**Removed:**
- `SEED_INVENTORY` hardcoded array
- Automatic seeding on app load

**Added:**
- `openAddCommodityModal()` — New commodity registration form
- `submitAddCommodityModal()` — Handles commodity creation
- `loadDemoData()` — Loads demo commodities to localStorage
- Enhanced `renderPantry()` — Shows empty state with onboarding
- Enhanced `renderDashboard()` — Shows welcome screen when empty

**Key Functions:**
```javascript
// Add a new commodity (localStorage)
addInventoryItem({
  name: "Toor Dal",
  category: "Pulses",
  qty: 0,  // Always starts at 0
  unit: "kg",
  threshold: 1.0,
  storageLocation: "Container C",
  deviceId: "ESP32_003",
  rfidTagId: "RFID003",
  rfTagId: "RF003"
})

// Load demo data (for testing)
loadDemoData()

// Delete a commodity
deleteInventoryItem(id)

// Adjust quantity (via IoT simulation only, not for manual entry)
adjustInventory(id, delta)
```

---

## DATA MODEL

### Commodity Record (Master Data)
```javascript
{
  id: "PULSE001",
  itemId: "PULSE001",
  name: "Toor Dal",
  category: "Pulses",
  minimumQuantity: 1.0,
  unit: "kg",
  storageLocation: "Container C",
  
  // Hardware mapping
  deviceId: "ESP32_003",
  rfidTagId: "RFID003",
  rfTagId: "RF003",
  
  // Live state (updated by sensors)
  currentQuantity: 2.35,
  status: "AVAILABLE",
  lastUpdated: "2026-09-01T10:30:45.123Z",
  createdAt: "2026-09-01T08:00:00.000Z"
}
```

### Status Values
```
AVAILABLE    → quantity > minimumQuantity
LOW_STOCK    → 0 < quantity ≤ minimumQuantity
OUT_OF_STOCK → quantity = 0
```

### Sensor Reading Record
```javascript
{
  readingId: "ESP32_003_2026-09-01T...",
  deviceId: "ESP32_003",
  itemId: "PULSE001",
  sensorType: "weight",
  value: 2.35,
  valueKg: 2.35,
  unit: "kg",
  timestamp: "2026-09-01T10:30:45.123Z",
  changeKg: -0.15  // Previous: 2.50, Now: 2.35
}
```

---

## TESTING GUIDE

### Test 1: Empty Start
1. Clear localStorage (F12 → Application → Clear)
2. Refresh app
3. Should show Dashboard welcome screen
4. Pantry should be empty with onboarding

### Test 2: Manual Commodity Registration
1. Go to Pantry
2. Click "+ Add commodity"
3. Enter:
   - Name: "Test Rice"
   - Category: "Grains"
   - Min: 2.0
   - Unit: "kg"
4. Click Register
5. Should appear with quantity 0, status OUT_OF_STOCK

### Test 3: Demo Data Loader
1. Go to Pantry (empty)
2. Click "📦 Load demo commodities"
3. Should show 6 items
4. Each should have quantity 0
5. Click again → Should say all already exist

### Test 4: Backend Validation (Unknown Device)
```bash
curl -X POST http://localhost:8000/api/iot/sensor \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "ESP32_UNKNOWN",
    "itemId": "ITEM_DOES_NOT_EXIST",
    "value": 2.5
  }'

# Expected response 422:
# "Unknown commodity itemId: ITEM_DOES_NOT_EXIST"
```

### Test 5: Backend Validation (Unregistered Device)
```bash
# First, manually register a commodity without device mapping:
curl -X POST http://localhost:8000/api/commodities \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Wheat",
    "category": "Grains",
    "minimumQuantity": 2.0,
    "unit": "kg"
  }'
# Returns itemId (e.g., GRAIN_123)

# Now try to send data from wrong device:
curl -X POST http://localhost:8000/api/iot/sensor \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "ESP32_999",
    "itemId": "GRAIN_123",
    "value": 2.5
  }'

# Expected response 422:
# "Commodity Wheat has no device mapped."
```

### Test 6: Correct Device Flow
```bash
# 1. Register commodity with device
curl -X POST http://localhost:8000/api/commodities \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Toor Dal",
    "category": "Pulses",
    "minimumQuantity": 1.0,
    "unit": "kg",
    "deviceId": "ESP32_003"
  }'
# Returns: itemId = PULSE_123

# 2. Send sensor data from correct device
curl -X POST http://localhost:8000/api/iot/sensor \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "ESP32_003",
    "itemId": "PULSE_123",
    "value": 2.35
  }'

# Expected response 200:
{
  "success": true,
  "itemId": "PULSE_123",
  "quantity": 2.35,
  "status": "AVAILABLE"
}

# 3. Check GET /api/inventory — Toor Dal should show 2.35 kg
```

---

## ABSOLUTE RULES (NON-NEGOTIABLE)

✅ **MUST DO:**
1. Start with empty system
2. Manual commodity registration only
3. Validate device against commodity mapping
4. Reject unknown devices
5. Separate master data from live data
6. Use Firebase as source of truth
7. Dashboard reflects database state
8. Demo data is optional, not automatic
9. No fake inventory generation
10. AI analyzes only registered commodities

❌ **MUST NOT:**
1. Auto-load seed data on startup
2. Allow unknown devices to create commodities
3. Automatically generate grocery names
4. Use AI to invent items
5. Pre-populate commodities
6. Mix device events with item creation
7. Allow ESP32 to directly modify master data
8. Generate fake sensor readings
9. Create shortcuts that bypass validation
10. Show data that isn't in the database

---

## MIGRATION GUIDE (If upgrading from old version)

### For Existing Users
1. **Backup your data:**
   ```bash
   # Export Firebase data or localStorage
   JSON.stringify(JSON.parse(localStorage.getItem('brainy_basket_v2')))
   ```

2. **Clear old seed data:**
   ```javascript
   // In browser console:
   localStorage.removeItem('brainy_basket_v2');
   location.reload();
   ```

3. **Start fresh:**
   - App shows empty dashboard
   - Manually re-add your commodities
   - Or load demo data for quick testing

### For Developers
1. Deploy new `commodity_service.py` to backend
2. Update `main.py` with new endpoints
3. Update `inventory_service.py` (remove seed functions)
4. Deploy new `app.js` (remove SEED_INVENTORY)
5. Clear old Firebase data or migrate programmatically

---

## FAQ

**Q: Can I still use the demo data?**
A: Yes! Use the "📦 Load demo commodities" button or `POST /api/demo/load-sample-commodities`

**Q: What if I already have commodities from the old version?**
A: You'll need to re-add them. The new system is designed to prevent this - users should manage their data explicitly.

**Q: Can the ESP32 create commodities automatically?**
A: No. Never. The backend will return a 422 error if you try to send data for an unknown commodity.

**Q: What if I send data from an unknown device?**
A: Backend rejects it with a clear error message. Device must be registered and mapped first.

**Q: Can AI create commodities?**
A: No. AI can only analyze the commodities you've manually registered.

**Q: Where does the quantity come from?**
A: Only from validated ESP32 sensor readings. Never from AI or manual entry (except through the IoT simulation for testing).

**Q: How do I test without physical hardware?**
A: Use the IoT Monitor panel with simulation buttons, or call `/api/iot/sensor` directly with correct device/item IDs.

---

## TROUBLESHOOTING

### Issue: Dashboard shows empty state
**Solution:** This is correct! App starts empty. Go to Pantry and add a commodity.

### Issue: Backend returns "Unknown commodity"
**Solution:** You need to register the commodity first via `POST /api/commodities`

### Issue: "Device not registered for this commodity"
**Solution:** Map the device using `POST /api/commodities/{id}/map-device`

### Issue: Sensor readings not updating dashboard
**Check:**
1. Commodity exists and is registered
2. Device is mapped to commodity
3. Device ID in sensor payload matches
4. itemId is correct
5. Check `/api/sensor-readings` for the reading
6. Check `/api/inventory` for updated quantity

### Issue: Demo data won't load
**Solution:**
- Clear localStorage: `localStorage.removeItem('brainy_basket_v2')`
- Try again
- Or use API: `POST /api/demo/load-sample-commodities`

---

## SUMMARY

The Brainy Basket system now follows strict manual configuration principles:

1. **No automatic commodity creation** — Users add items explicitly
2. **Device validation** — Unknown devices are rejected
3. **Separated master/live data** — Configuration vs sensor readings
4. **Clear error messages** — Users know why operations fail
5. **Optional demo data** — For testing, not automatic
6. **Empty start state** — Matches user expectations
7. **Real-time updates** — Dashboard reflects database
8. **Professional architecture** — Ready for production use

The system is now **correct, modular, secure, and scalable** while adhering to the "IoT system is the source of truth" principle.

---

**Document version:** 1.0  
**Last updated:** 2026-09-01  
**Status:** Implementation Complete ✅
