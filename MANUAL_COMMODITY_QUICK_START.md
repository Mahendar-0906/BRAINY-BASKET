# BRAINY BASKET v2.1 — QUICK START GUIDE

## What's New: Manual Commodity Configuration

The Brainy Basket system has been completely redesigned to follow the **"Manual Configuration First"** principle:

- ✅ **App starts empty** — No hardcoded demo data
- ✅ **Users register commodities** — Name, category, minimum, unit, location
- ✅ **Hardware is validated** — Unknown devices are rejected
- ✅ **Live quantity comes from sensors** — Not from AI or manual entry
- ✅ **Dashboard reflects database** — Real-time, no fake state
- ✅ **Optional demo data** — For testing only, not automatic

---

## 30-Second Start

### Option 1: Demo Mode (for testing)
```
1. Open app
2. Go to Pantry
3. Click "📦 Load demo commodities"
4. 6 sample items appear
5. Try IoT simulation buttons
```

### Option 2: Manual Setup (production)
```
1. Open app
2. Go to Pantry
3. Click "+ Add commodity"
4. Fill in your first item (e.g., Toor Dal)
5. Map ESP32 device ID
6. Physical sensor updates quantity
```

---

## Files Modified

### Backend
- ✨ **NEW:** `backend/commodity_service.py` — Commodity CRUD + device validation
- 📝 **MODIFIED:** `backend/main.py` — Added 6 new API endpoints
- 📝 **MODIFIED:** `backend/inventory_service.py` — Removed seed, added validation

### Frontend
- 📝 **MODIFIED:** `app.js` — Removed seed data, added commodity management UI

### Documentation
- ✨ **NEW:** `MANUAL_COMMODITY_CONFIGURATION_GUIDE.md` — Comprehensive guide (this file!)

---

## Core API Endpoints

### Create Commodity (Manual)
```bash
POST /api/commodities
{
  "name": "Toor Dal",
  "category": "Pulses",
  "minimumQuantity": 1.0,
  "unit": "kg",
  "storageLocation": "Container C",
  "deviceId": "ESP32_003"
}
```

### List All Commodities
```bash
GET /api/commodities
```

### Update Commodity
```bash
PUT /api/commodities/{commodity_id}
```

### Map Hardware
```bash
POST /api/commodities/{commodity_id}/map-device
{
  "deviceId": "ESP32_003",
  "rfidTagId": "RFID003",
  "rfTagId": "RF003"
}
```

### Send Sensor Data (unchanged, but now validates)
```bash
POST /api/iot/sensor
{
  "deviceId": "ESP32_003",
  "itemId": "PULSE001",
  "value": 2.35,
  "unit": "kg"
}
```

### Load Demo Commodities
```bash
POST /api/demo/load-sample-commodities
```

---

## Key Differences from v2.0

| Feature | v2.0 | v2.1 |
|---------|------|------|
| Start state | Pre-loaded 12 items | Empty (0 items) |
| Commodity creation | Auto-seeded | Manual only |
| Unknown device handling | Possible issues | Rejected with error |
| Master vs Live data | Mixed | Separated |
| Demo data | Automatic | Optional button |
| Device validation | Weak | Strict |
| Error messages | Generic | Specific |

---

## Testing Without Hardware

Use IoT Monitor simulation buttons:
- "Simulate restock"
- "Simulate consumption"
- "Simulate low stock"
- etc.

These go through the same backend validation as real hardware.

---

## Production Deployment Checklist

- [ ] Deploy new `backend/commodity_service.py`
- [ ] Update `backend/main.py` with commodity endpoints
- [ ] Update `backend/inventory_service.py` (remove seeds)
- [ ] Deploy updated `app.js` (no seed data)
- [ ] Clear old Firebase/localStorage if upgrading
- [ ] Test: Create commodity → Send sensor → See update
- [ ] Test: Unknown device rejection
- [ ] Test: Demo data loader
- [ ] Update user documentation

---

## Common Tasks

### Add Your First Commodity
```
Pantry → + Add Commodity → Fill form → Register
```

### Test with Demo Data
```
Pantry (empty) → Load demo commodities → 6 items appear
```

### Send Sensor Data (API)
```bash
curl -X POST http://localhost:8000/api/iot/sensor \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "ESP32_003",
    "itemId": "PULSE001",
    "value": 2.35
  }'
```

### Check Current Inventory
```bash
curl http://localhost:8000/api/inventory
```

### List All Commodities
```bash
curl http://localhost:8000/api/commodities
```

---

## Architecture Summary

```
User registers commodity manually
        ↓
Commodity stored in Firebase (master data)
        ↓
User maps ESP32 device to commodity
        ↓
Physical sensor measures
        ↓
ESP32 sends: {deviceId, itemId, value}
        ↓
Backend validates:
  - Commodity exists?
  - Device mapped to commodity?
  - Value valid?
        ↓
Firebase updated with live quantity
        ↓
Dashboard listener catches update
        ↓
UI refreshes automatically
```

---

## Critical Rules

1. ✅ Users must manually register commodities
2. ✅ Every device must be mapped before sending data
3. ✅ Unknown devices are always rejected
4. ✅ Quantity comes ONLY from validated sensors
5. ✅ Firebase is the single source of truth
6. ✅ Dashboard shows database state, nothing else
7. ✅ AI analyzes registered commodities only
8. ✅ No automatic commodity creation ever
9. ✅ Demo data is optional, not automatic
10. ✅ Clear error messages for all failures

---

## Next Steps

1. **Read:** `MANUAL_COMMODITY_CONFIGURATION_GUIDE.md` for detailed info
2. **Test:** Use Pantry UI or API to add a commodity
3. **Deploy:** Follow checklist above
4. **Integrate:** Connect your real ESP32 hardware
5. **Monitor:** Check backend logs for validation

---

**Questions?** See `MANUAL_COMMODITY_CONFIGURATION_GUIDE.md` for FAQ and troubleshooting.

Version 2.1 | Manual Configuration | Ready for Production ✅
