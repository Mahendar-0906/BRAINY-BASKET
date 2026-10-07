"""Brainy Basket API: ESP32 measurements become authoritative inventory state."""
from __future__ import annotations

import os
from typing import Any, Optional

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field

from .firebase_service import store
from .inventory_service import inventory_snapshot, process_sensor_reading
from .commodity_service import (
    create_commodity,
    get_commodity,
    list_commodities,
    update_commodity,
    delete_commodity,
    map_device_to_commodity,
    validate_device_for_commodity,
)
from .nutrition_service import (
    ensure_nutrition_seed_data,
    list_food_items,
    get_food_item,
    get_household_members,
    create_household_member,
    log_meal,
    get_daily_nutrition,
    get_weekly_nutrition,
    get_nutrition_progress,
    get_food_source_analysis,
    get_nutrition_targets,
)

app = FastAPI(title="Brainy Basket AI & IoT API", version="2.0.0")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])


class SensorPayload(BaseModel):
    deviceId: str = Field(min_length=1, max_length=100)
    itemId: str = Field(min_length=1, max_length=100)
    sensorType: str = "weight"
    value: float = Field(ge=0, le=10000)
    unit: str = "kg"
    timestamp: Optional[str] = None


class PurchasePayload(BaseModel):
    quantity: float = Field(gt=0, le=10000)


@app.get("/api/health")
@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": "brainy-basket-backend", "database": store.backend}


# ──────────────────────────────────────────────────────────────────────────
# COMMODITY MANAGEMENT API ENDPOINTS
# ──────────────────────────────────────────────────────────────────────────

class CreateCommodityPayload(BaseModel):
    name: str = Field(min_length=1, max_length=200)
    category: str = Field(min_length=1, max_length=100)
    minimumQuantity: float = Field(ge=0, le=10000)
    unit: str = "kg"
    storageLocation: Optional[str] = None
    rfidTagId: Optional[str] = None
    rfTagId: Optional[str] = None
    deviceId: Optional[str] = None


@app.post("/api/commodities")
def create_new_commodity(payload: CreateCommodityPayload) -> dict[str, Any]:
    """Manually register a new commodity."""
    try:
        commodity = create_commodity(
            name=payload.name,
            category=payload.category,
            minimum_quantity=payload.minimumQuantity,
            unit=payload.unit,
            storage_location=payload.storageLocation or "",
            rfid_tag_id=payload.rfidTagId,
            rf_tag_id=payload.rfTagId,
            device_id=payload.deviceId,
        )
        return {"success": True, "commodity": commodity}
    except ValueError as error:
        raise HTTPException(status_code=422, detail=str(error)) from error


@app.get("/api/commodities")
def get_all_commodities() -> dict[str, Any]:
    """Get all manually registered commodities."""
    commodities = list_commodities()
    return {
        "commodities": commodities,
        "total": len(commodities),
        "principle": "All commodities are manually registered. ESP32 only updates quantity for pre-registered items.",
    }


@app.get("/api/commodities/{commodity_id}")
def get_single_commodity(commodity_id: str) -> dict[str, Any]:
    """Get a single commodity by ID."""
    commodity = get_commodity(commodity_id)
    if not commodity:
        raise HTTPException(status_code=404, detail=f"Commodity not found: {commodity_id}")
    return {"commodity": commodity}


class UpdateCommodityPayload(BaseModel):
    name: Optional[str] = None
    category: Optional[str] = None
    minimumQuantity: Optional[float] = None
    unit: Optional[str] = None
    storageLocation: Optional[str] = None
    rfidTagId: Optional[str] = None
    rfTagId: Optional[str] = None
    deviceId: Optional[str] = None


@app.put("/api/commodities/{commodity_id}")
def update_single_commodity(commodity_id: str, payload: UpdateCommodityPayload) -> dict[str, Any]:
    """Update commodity master data (configuration only, not live quantity)."""
    try:
        updated = update_commodity(
            commodity_id=commodity_id,
            name=payload.name,
            category=payload.category,
            minimum_quantity=payload.minimumQuantity,
            unit=payload.unit,
            storage_location=payload.storageLocation,
            rfid_tag_id=payload.rfidTagId,
            rf_tag_id=payload.rfTagId,
            device_id=payload.deviceId,
        )
        return {"success": True, "commodity": updated}
    except ValueError as error:
        raise HTTPException(status_code=422, detail=str(error)) from error


@app.delete("/api/commodities/{commodity_id}")
def delete_single_commodity(commodity_id: str) -> dict[str, Any]:
    """Delete a commodity."""
    try:
        delete_commodity(commodity_id)
        return {"success": True, "message": f"Commodity {commodity_id} deleted"}
    except ValueError as error:
        raise HTTPException(status_code=422, detail=str(error)) from error


class MapDevicePayload(BaseModel):
    deviceId: str = Field(min_length=1, max_length=100)
    rfidTagId: Optional[str] = None
    rfTagId: Optional[str] = None


@app.post("/api/commodities/{commodity_id}/map-device")
def map_hardware_to_commodity(commodity_id: str, payload: MapDevicePayload) -> dict[str, Any]:
    """Manually map hardware (device, RFID, RF tags) to a commodity."""
    try:
        commodity = map_device_to_commodity(
            commodity_id=commodity_id,
            device_id=payload.deviceId,
            rfid_tag_id=payload.rfidTagId,
            rf_tag_id=payload.rfTagId,
        )
        return {"success": True, "commodity": commodity}
    except ValueError as error:
        raise HTTPException(status_code=422, detail=str(error)) from error


@app.get("/api/inventory")
def get_inventory() -> dict[str, Any]:
    return {
        "inventory": inventory_snapshot(),
        "database": store.backend,
        "principle": "Displays only manually registered commodities with their current live state (updated by ESP32 sensor readings).",
    }



@app.get("/api/alerts")
def get_alerts() -> dict[str, Any]:
    return {"alerts": store.list("alerts")[-50:]}


@app.get("/api/sensor-readings")
def get_sensor_readings() -> dict[str, Any]:
    return {"readings": store.list("sensor_readings")[-200:]}


@app.get("/api/iot/devices")
def get_devices() -> dict[str, Any]:
    return {"devices": store.list("iot_devices")}


@app.post("/api/iot/sensor")
def receive_sensor(payload: SensorPayload) -> dict[str, Any]:
    try:
        return process_sensor_reading(payload.deviceId, payload.itemId, payload.sensorType, payload.value, payload.unit, payload.timestamp)
    except ValueError as error:
        raise HTTPException(status_code=422, detail=str(error)) from error


@app.post("/api/iot/events")
def legacy_iot_event(event: dict[str, Any]) -> dict[str, Any]:
    """Compatibility adapter for older clients; all updates use the sensor workflow."""
    payload = event.get("payload", {})
    item_name = payload.get("itemName")
    item = next((item for item in inventory_snapshot() if item["name"].lower() == str(item_name).lower()), None)
    if not item or payload.get("quantity") is None:
        raise HTTPException(status_code=422, detail="payload.itemName and payload.quantity are required")
    return process_sensor_reading(event.get("deviceId", item.get("deviceId", "ESP32_001")), item["itemId"], "weight", float(payload["quantity"]), "kg")


@app.post("/api/inventory/{item_id}/purchase")
def purchase_inventory(item_id: str, payload: PurchasePayload) -> dict[str, Any]:
    item = next((item for item in inventory_snapshot() if item["itemId"] == item_id), None)
    if not item:
        raise HTTPException(status_code=404, detail="unknown itemId")
    result = process_sensor_reading(item.get("deviceId", "manual_purchase"), item_id, "weight", item["quantity"] + payload.quantity, "kg")
    store.add("activity_logs", {"event": "purchase", "message": f"{item['name']} purchased: {payload.quantity:.2f} kg", "itemId": item_id})
    return result


# ──────────────────────────────────────────────────────────────────────────
# NUTRITION TRACKING API ENDPOINTS
# ──────────────────────────────────────────────────────────────────────────

@app.get("/api/nutrition/foods")
def get_all_foods() -> dict[str, Any]:
    """Get all food items from the nutrition database."""
    ensure_nutrition_seed_data()
    return {"foods": list_food_items(), "note": "All nutrition values are ESTIMATED"}


@app.get("/api/nutrition/foods/{food_id}")
def get_food(food_id: str) -> dict[str, Any]:
    """Get a specific food item."""
    ensure_nutrition_seed_data()
    food = get_food_item(food_id)
    if not food:
        raise HTTPException(status_code=404, detail="Food not found")
    return {"food": food, "note": "Nutrition values are ESTIMATED"}


@app.get("/api/nutrition/household/{user_id}")
def get_members(user_id: str) -> dict[str, Any]:
    """Get all household members for a user."""
    members = get_household_members(user_id)
    return {"members": members}


class HouseholdMemberPayload(BaseModel):
    personId: str
    name: str
    age: int
    height: float  # cm
    weight: float  # kg
    activityLevel: str  # sedentary, light, moderate, active, veryActive
    nutritionGoal: str  # balanced, highProtein, weightManagement, wellness


@app.post("/api/nutrition/household/{user_id}")
def add_household_member(user_id: str, payload: HouseholdMemberPayload) -> dict[str, Any]:
    """Create a new household member."""
    member = create_household_member(
        user_id=user_id,
        person_id=payload.personId,
        name=payload.name,
        age=payload.age,
        height=payload.height,
        weight=payload.weight,
        activity_level=payload.activityLevel,
        nutrition_goal=payload.nutritionGoal,
    )
    targets = get_nutrition_targets(member)
    return {"member": member, "targets": targets}


class MealLogPayload(BaseModel):
    mealType: str  # Breakfast, Lunch, Dinner, Snack
    date: str  # ISO format: YYYY-MM-DD
    ingredients: list[dict[str, Any]]  # [{foodId, quantity, unit}, ...]
    recipeId: Optional[str] = None
    notes: Optional[str] = None


@app.post("/api/nutrition/meal-logs/{person_id}")
def log_person_meal(person_id: str, payload: MealLogPayload) -> dict[str, Any]:
    """Log a meal for a person."""
    meal = log_meal(
        person_id=person_id,
        meal_type=payload.mealType,
        date=payload.date,
        ingredients=payload.ingredients,
        recipe_id=payload.recipeId,
        notes=payload.notes,
    )
    return {"meal": meal, "note": "Nutrition values are ESTIMATED based on meal ingredients"}


@app.get("/api/nutrition/daily/{person_id}/{date}")
def get_person_daily_nutrition(person_id: str, date: str) -> dict[str, Any]:
    """Get daily nutrition summary for a person (date format: YYYY-MM-DD)."""
    result = get_daily_nutrition(person_id, date)
    return {**result, "note": "All nutrition values are ESTIMATED"}


@app.get("/api/nutrition/weekly/{person_id}/{date}")
def get_person_weekly_nutrition(person_id: str, date: str) -> dict[str, Any]:
    """Get weekly nutrition analysis starting from date (date format: YYYY-MM-DD)."""
    result = get_weekly_nutrition(person_id, date)
    return {**result, "note": "All nutrition values are ESTIMATED"}


@app.get("/api/nutrition/progress/{person_id}/{date}")
def get_person_nutrition_progress(person_id: str, date: str) -> dict[str, Any]:
    """Get nutrition progress vs targets for a person."""
    result = get_nutrition_progress(person_id, date)
    return {**result, "note": "Targets are calculated estimates based on member profile; not medical prescriptions"}


@app.get("/api/nutrition/food-sources/{person_id}/{date}")
def get_person_food_sources(person_id: str, date: str) -> dict[str, Any]:
    """Analyze which foods contributed most to nutrient intake."""
    result = get_food_source_analysis(person_id, date)
    return {**result, "note": "Analysis based on logged meals"}


@app.get("/api/recommendations")
def recommendations() -> dict[str, Any]:
    """Recipe recommendations based only on manually registered commodities."""
    available = {item["name"].lower() for item in inventory_snapshot() if item.get("currentQuantity", 0) > 0}
    return {
        "recommendations": [],
        "availableCommodities": list(available),
        "note": "Add recipes via the pantry UI. Recommendations are matched against your registered commodities only.",
    }


STATIC_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
app.mount("/", StaticFiles(directory=STATIC_DIR, html=True), name="static")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.main:app", host="127.0.0.1", port=8082, reload=True)
